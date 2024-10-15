package suite_test

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	v1 "k8s.io/api/apps/v1"
	coreV1 "k8s.io/api/core/v1"
)

type TemplateMembership struct {
	TemplateChart
}

func TestMembership(t *testing.T) {
	// could be ldflags, but does not seem to work with go test ./... -ldflags "-X tests/helm/suite_test.ChartPath=../../charts/cloudprem"
	if chartDirFromEnv := os.Getenv("CHART_DIR"); chartDirFromEnv != "" {
		chartDir = chartDirFromEnv
	}

	chartPath, err := filepath.Abs(filepath.Join(chartDir + "membership"))
	require.NoError(t, err)

	chartTest := &TemplateMembership{
		TemplateChart{
			TemplateGoldenTest{
				Base{
					ChartPath: chartPath,
					Release:   releaseName,
					Name:      "membership",
					Namespace: "ccsm-helm-" + strings.ToLower(random.UniqueId()),
					setValues: map[string]string{},
				},
			},
		},
	}

	chartTest.setupSuite(t)
	suite.Run(t, chartTest)
}

func (s *TemplateMembership) TestsWithoutPG() {
	t := s.T()
	t.Parallel()

	t.Run(t.Name()+"_should template without postgresql", func(t *testing.T) {
		options := s.Options()
		options.SetValues["postgresql.enabled"] = "false"

		_, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{})
		require.NoError(t, err)
	})
}

func (s *TemplateMembership) TestsWithSecrets() {
	t := s.T()
	t.Parallel()

	for _, pgEnabled := range []bool{true, false} {
		t.Run(t.Name()+"with secrets, pg enabled: "+strconv.FormatBool(pgEnabled), func(t *testing.T) {
			t.Parallel()
			options := s.Options()
			options.SetValues["postgresql.enabled"] = strconv.FormatBool(pgEnabled)
			if !pgEnabled {
				options.SetValues["global.postgresql.host"] = "localhost"
			}

			options.SetValues["global.postgresql.auth.existingSecret"] = uuid.NewString()
			options.SetValues["global.postgresql.auth.secretKeys.adminPasswordKey"] = uuid.NewString()

			templateNames := []string{"deployment", "dex/secret"}
			for _, templateName := range templateNames {
				t.Run(t.Name()+"templates:"+strings.Join(templateNames, ","), func(t *testing.T) {
					output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
					require.NoError(t, err)
					switch templateName {
					case "deployment":
						r := v1.Deployment{}
						helm.UnmarshalK8SYaml(t, output, &r)
					case "dex/secret":
						r := coreV1.Secret{}
						helm.UnmarshalK8SYaml(t, output, &r)
					default:
						t.Fatal("unknown template")
					}
				})
			}
		})
	}
}

func (s *TemplateMembership) TestManagedStack() {
	t := s.T()
	t.Parallel()
	templateNames := []string{"service", "deployment"}

	for _, managedStack := range []bool{true, false} {
		options := s.Options()
		options.SetValues["feature.managedStacks"] = strconv.FormatBool(managedStack)

		for _, templateName := range templateNames {
			if managedStack {
				switch templateName {
				case "service":
					t.Run(fmt.Sprintf("%s-managed", templateName), func(t *testing.T) {
						output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
						require.NoError(t, err)
						var r coreV1.Service
						helm.UnmarshalK8SYaml(t, output, &r)
						require.Len(t, r.Spec.Ports, 1)
						require.Equal(t, r.Spec.Ports[0].Name, "http")
					})
				case "deployment":
					t.Run(fmt.Sprintf("%s-managed", templateName), func(t *testing.T) {
						output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
						require.NoError(t, err)
						var r v1.Deployment
						helm.UnmarshalK8SYaml(t, output, &r)
						require.Len(t, r.Spec.Template.Spec.Containers, 1)
						require.Len(t, r.Spec.Template.Spec.Containers[0].Ports, 1)
						require.Equal(t, r.Spec.Template.Spec.Containers[0].Ports[0].Name, "http")
					})
				default:
					t.Skipf("Skipping test: %s", templateName)
				}
			} else {
				switch templateName {
				case "service":
					t.Run(fmt.Sprintf("%s-not-managed", templateName), func(t *testing.T) {
						output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
						require.NoError(t, err)
						var r coreV1.Service
						helm.UnmarshalK8SYaml(t, output, &r)
						require.Len(t, r.Spec.Ports, 2)
						require.Equal(t, r.Spec.Ports[0].Name, "http")
						require.Equal(t, r.Spec.Ports[1].Name, "grpc")
					})
				case "deployment":
					t.Run(fmt.Sprintf("%s-not-managed", templateName), func(t *testing.T) {
						output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
						require.NoError(t, err)
						var r v1.Deployment
						helm.UnmarshalK8SYaml(t, output, &r)
						require.Len(t, r.Spec.Template.Spec.Containers, 1)
						require.Len(t, r.Spec.Template.Spec.Containers[0].Ports, 2)
						require.Equal(t, r.Spec.Template.Spec.Containers[0].Ports[0].Name, "http")
						require.Equal(t, r.Spec.Template.Spec.Containers[0].Ports[1].Name, "grpc")
					})
				default:
					t.Skipf("Skipping test: %s", templateName)
				}
			}
		}
	}

}

func (s *TemplateMembership) TestDeploymentConfigMapping() {
	t := s.T()
	t.Parallel()
	templateNames := []string{"configmap", "deployment"}
	options := s.Options()
	for _, templateName := range templateNames {
		t.Run(fmt.Sprintf("membership-%s-config-mapping", templateName), func(t *testing.T) {
			output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
			require.NoError(t, err)
			switch templateName {
			case "configmap":
				r := coreV1.ConfigMap{}
				helm.UnmarshalK8SYaml(t, output, &r)
				require.Equal(t, r.Name, fmt.Sprintf("%s-%s", s.Release, s.Name))
			case "deployment":
				r := v1.Deployment{}
				helm.UnmarshalK8SYaml(t, output, &r)

				require.Len(t, r.Spec.Template.Spec.Volumes, 1)
				require.Equal(t, r.Spec.Template.Spec.Volumes[0].ConfigMap.Name, fmt.Sprintf("%s-%s", s.Release, s.Name))
			}
		})
	}
}

func (s *TemplateMembership) TestConsoleBaseUrl() {
	t := s.T()
	t.Parallel()
	for _, withConsole := range []bool{false, true} {
		t.Run(fmt.Sprintf("%s-with-%s", t.Name(), strconv.FormatBool(withConsole)), func(t *testing.T) {
			t.Parallel()
			var values map[string]string
			if withConsole {
				values = map[string]string{
					"global.platform.console.host":   "console.example.com",
					"global.platform.console.scheme": "https",
				}
			}

			options := s.Options(
				WithValues(values),
			)
			output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{"templates/deployment.yaml"})
			require.NoError(t, err)
			r := v1.Deployment{}
			helm.UnmarshalK8SYaml(t, output, &r)
			if withConsole {
				require.Contains(t, r.Spec.Template.Spec.Containers[0].Env, coreV1.EnvVar{
					Name:  "CONSOLE_PUBLIC_BASEURL",
					Value: fmt.Sprintf("%s://%s", values["global.platform.console.scheme"], values["global.platform.console.host"]),
				})
				return
			}
		})
	}
}
