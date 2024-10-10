package suite_test

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	v1 "k8s.io/api/apps/v1"
	coreV1 "k8s.io/api/core/v1"
	networkingV1 "k8s.io/api/networking/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
)

// https://medium.com/@zelldon91/advanced-test-practices-for-helm-charts-587caeeb4cb
type TemplateGoldenTest struct {
	Base
}

func TestCharts(t *testing.T) {
	// could be ldflags, but does not seem to work with go test ./... -ldflags "-X tests/helm/suite_test.ChartPath=../../charts/cloudprem"
	if chartDirFromEnv := os.Getenv("CHART_DIR"); chartDirFromEnv != "" {
		chartDir = chartDirFromEnv
	}

	for _, chart := range charts {
		chartPath, err := filepath.Abs(chartDir + chart)
		require.NoError(t, err)

		chartTest := &TemplateChart{
			TemplateGoldenTest{
				Base{
					ChartPath: chartPath,
					Name:      chart,
					Release:   releaseName,
					Namespace: "ccsm-helm-" + strings.ToLower(random.UniqueId()),
					setValues: map[string]string{},
				},
			},
		}

		t.Run(chart, func(t *testing.T) {
			t.Parallel()
			require.NoError(t, chartTest.setupSuite(t))
			suite.Run(t, chartTest)
		})
	}
}

func (s *TemplateChart) TestLabelAndNaming() {
	t := s.T()
	t.Parallel()

	appDir := fmt.Sprint(s.ChartPath + "/templates")
	dirEntries, err := os.ReadDir(appDir)
	require.NoError(t, err)
	templateNames := []string{}
	for _, dirEntry := range dirEntries {
		if strings.HasSuffix(dirEntry.Name(), ".yaml") {
			templateNames = append(templateNames, dirEntry.Name())
		}
	}

	for _, templateName := range templateNames {
		t.Run(fmt.Sprintf("labels-%s-%s", s.Name, templateName), s.testLabels(templateName))
		t.Run(fmt.Sprintf("names-%s-%s", s.Name, templateName), s.testNames(templateName))
	}

}

func (s *TemplateChart) testLabels(templateName string) func(t *testing.T) {
	return func(t *testing.T) {
		values := make(map[string]string, 0)
		switch templateName {
		case "hpa.yaml":
			values["autoscaling.enabled"] = "true"
		case "ingress.yaml":
			values["ingress.enabled"] = "true"
		case "pdp.yaml":
			values["podDisruptionBudget.enabled"] = "true"
		}
		options := s.Options()
		for k, v := range values {
			options.SetValues[k] = v
		}
		output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s", templateName)})
		require.NoError(t, err)

		r := unstructured.Unstructured{}
		helm.UnmarshalK8SYaml(t, output, &r)

		labels := r.GetLabels()
		require.NotNil(t, labels)
		require.Contains(t, labels, "app.kubernetes.io/version")

		require.Contains(t, labels, "app.kubernetes.io/name")
		require.Equal(t, labels["app.kubernetes.io/name"], s.Name)

		require.Contains(t, labels, "app.kubernetes.io/instance")
		require.Equal(t, labels["app.kubernetes.io/instance"], s.Release)

		require.Contains(t, labels, "app.kubernetes.io/managed-by")
		require.Equal(t, labels["app.kubernetes.io/managed-by"], "Helm")
	}
}

func (s *TemplateChart) testNames(templateName string) func(t *testing.T) {
	return func(t *testing.T) {
		t.Parallel()
		values := make(map[string]string, 0)
		switch templateName {
		case "hpa.yaml":
			values["autoscaling.enabled"] = "true"
		case "ingress.yaml":
			values["ingress.enabled"] = "true"
		case "pdp.yaml":
			values["podDisruptionBudget.enabled"] = "true"
		}
		options := s.Options()
		for k, v := range values {
			options.SetValues[k] = v
		}
		output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s", templateName)})
		require.NoError(t, err)
		r := unstructured.Unstructured{}
		helm.UnmarshalK8SYaml(t, output, &r)
		switch r.GetKind() {
		case "Job":
			require.Contains(t, r.GetName(), s.Release)
		default:
			require.Equal(t, r.GetName(), fmt.Sprintf("%s-%s", s.Release, s.Name))
		}
	}
}

func (s *TemplateChart) TestService() {
	t := s.T()
	t.Parallel()

	templateName := "service"

	t.Run(fmt.Sprintf("service-%s-%s", s.Name, templateName), func(t *testing.T) {
		t.Parallel()
		output, err := helm.RenderTemplateE(t, s.Options(), s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
		require.NoError(t, err)
		r := coreV1.Service{}
		helm.UnmarshalK8SYaml(t, output, &r)

		require.GreaterOrEqual(t, len(r.Spec.Ports), 1)
	})

}

func (s *TemplateChart) TestServiceAccount() {
	t := s.T()
	t.Parallel()

	templateName := "serviceaccount"
	values := map[string]string{
		"serviceAccount.annotations.test\\.annotations": "test",
	}
	t.Run(fmt.Sprintf("serviceaccount-%s-%s", s.Name, templateName), func(t *testing.T) {
		t.Parallel()
		for _, withServiceAccount := range []bool{true, false} {
			t.Run(fmt.Sprintf("serviceaccount-%s-%s-create-%s", s.Name, templateName, strconv.FormatBool(withServiceAccount)), func(t *testing.T) {
				options := s.Options()
				options.SetValues["serviceAccount.create"] = strconv.FormatBool(withServiceAccount)
				for k, v := range values {
					options.SetValues[k] = v
				}

				output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
				if !withServiceAccount {
					require.Error(t, err)
					return
				}
				require.NoError(t, err)
				r := coreV1.ServiceAccount{}
				helm.UnmarshalK8SYaml(t, output, &r)

				require.Equal(t, r.Name, fmt.Sprintf("%s-%s", s.Release, s.Name))
				require.Len(t, r.Annotations, 1)
				require.Contains(t, r.Annotations, "test.annotations")
				require.Equal(t, r.Annotations["test.annotations"], "test")
			})
		}
	})

}

func (s *TemplateChart) TestDeploymentServiceAccount() {
	t := s.T()
	t.Parallel()

	templateName := "deployment"

	t.Run(fmt.Sprintf("deployment-%s-%s", s.Name, templateName), func(t *testing.T) {
		t.Parallel()
		output, err := helm.RenderTemplateE(t, s.Options(), s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
		require.NoError(t, err)
		r := v1.Deployment{}
		helm.UnmarshalK8SYaml(t, output, &r)

		require.NotNil(t, r.Spec.Template.Spec.ServiceAccountName)
		require.Equal(t, r.Spec.Template.Spec.ServiceAccountName, fmt.Sprintf("%s-%s", s.Release, s.Name))
	})

}
func (s *TemplateChart) TestIngress() {
	t := s.T()
	t.Parallel()

	templateName := "ingress"
	serviceHost := "example.com"
	options := s.Options()
	options.SetValues["global.serviceHost"] = serviceHost
	options.SetValues["ingress.enabled"] = "true"

	t.Run(fmt.Sprintf("ingress-%s-%s", s.Name, templateName), func(t *testing.T) {
		t.Parallel()

		output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
		require.NoError(t, err)
		r := networkingV1.Ingress{}
		helm.UnmarshalK8SYaml(t, output, &r)

		require.Len(t, r.Spec.Rules, 1)
		require.Len(t, r.Spec.Rules[0].HTTP.Paths, 1)
		require.NotNil(t, r.Spec.Rules[0].HTTP.Paths[0].Path)
		require.Equal(t, *r.Spec.Rules[0].HTTP.Paths[0].PathType, networkingV1.PathTypePrefix)
		require.Equal(t, r.Spec.Rules[0].Host, fmt.Sprintf("%s.%s", s.Name, serviceHost))
	})

}

func (s *TemplateGoldenTest) TestLivenessRediness() {
	t := s.T()
	t.Parallel()

	options := s.Options()
	templateName := "deployment"
	t.Run(fmt.Sprintf("liveness-readiness-%s-%s", s.Name, templateName), func(t *testing.T) {
		output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
		require.NoError(t, err)
		r := v1.Deployment{}
		helm.UnmarshalK8SYaml(t, output, &r)

		require.Len(t, r.Spec.Template.Spec.Containers, 1)
		require.NotNil(t, r.Spec.Template.Spec.Containers[0].LivenessProbe)
		require.NotNil(t, r.Spec.Template.Spec.Containers[0].ReadinessProbe)

		path := "/_healthcheck"
		if s.Name == "console" || s.Name == "portal" {
			path = "/_info"
		}
		require.Equal(t, r.Spec.Template.Spec.Containers[0].LivenessProbe.HTTPGet.Path, path)
		require.Equal(t, r.Spec.Template.Spec.Containers[0].ReadinessProbe.HTTPGet.Path, path)
	})

}

func (s *TemplateGoldenTest) TestResources() {
	t := s.T()
	t.Parallel()
	templateName := "deployment"

	values := map[string]string{
		"resources.limits.cpu":      "100m",
		"resources.limits.memory":   "128Mi",
		"resources.requests.cpu":    "100m",
		"resources.requests.memory": "128Mi",
	}

	for _, withResource := range []bool{true, false} {
		t.Run(fmt.Sprintf("resources-%s-%s-with-resources-%s", s.Name, templateName, strconv.FormatBool(withResource)), func(t *testing.T) {
			options := s.Options()
			if withResource {
				for k, v := range values {
					options.SetValues[k] = v
				}
			}
			output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
			require.NoError(t, err)
			r := v1.Deployment{}
			helm.UnmarshalK8SYaml(t, output, &r)

			require.Len(t, r.Spec.Template.Spec.Containers, 1)
			require.NotNil(t, r.Spec.Template.Spec.Containers[0].Resources)

			if withResource {
				require.Equal(t, r.Spec.Template.Spec.Containers[0].Resources.Limits.Cpu().String(), values["resources.limits.cpu"])
				require.Equal(t, r.Spec.Template.Spec.Containers[0].Resources.Requests.Cpu().String(), values["resources.requests.cpu"])
				require.Equal(t, r.Spec.Template.Spec.Containers[0].Resources.Limits.Memory().String(), values["resources.limits.memory"])
				require.Equal(t, r.Spec.Template.Spec.Containers[0].Resources.Requests.Memory().String(), values["resources.requests.memory"])
			}
		})
	}

}

func (s *TemplateGoldenTest) TestNodeSelector() {
	t := s.T()
	t.Parallel()

	templateName := "deployment"

	values := map[string]string{
		"nodeSelector.kubernetes\\.io/hostname": "minikube",
	}

	for _, withNodeSelector := range []bool{true, false} {
		t.Run(fmt.Sprintf("node-selector-%s-%s-with-node-selector-%s", s.Name, templateName, strconv.FormatBool(withNodeSelector)), func(t *testing.T) {
			options := s.Options()
			if withNodeSelector {
				for k, v := range values {
					options.SetValues[k] = v
				}
			}
			output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
			require.NoError(t, err)
			r := v1.Deployment{}
			helm.UnmarshalK8SYaml(t, output, &r)

			if withNodeSelector {
				require.Len(t, r.Spec.Template.Spec.NodeSelector, len(values))
				require.Contains(t, r.Spec.Template.Spec.NodeSelector, "kubernetes.io/hostname")
				require.Equal(t, r.Spec.Template.Spec.NodeSelector["kubernetes.io/hostname"], values["nodeSelector.kubernetes\\.io/hostname"])
			} else {
				require.Len(t, r.Spec.Template.Spec.NodeSelector, 0)
			}

		})
	}

}

func (s *TemplateGoldenTest) TestTolerations() {
	t := s.T()
	t.Parallel()
	templateName := "deployment"

	values := map[string]string{
		"tolerations[0].key":      "key",
		"tolerations[0].operator": "Exists",
		"tolerations[0].effect":   "NoSchedule",
	}

	for _, withTolerations := range []bool{true, false} {
		t.Run(fmt.Sprintf("tolerations-%s-%s-with-tolerations-%s", s.Name, templateName, strconv.FormatBool(withTolerations)), func(t *testing.T) {
			options := s.Options()
			if withTolerations {
				for k, v := range values {
					options.SetValues[k] = v
				}
			}
			output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s.yaml", templateName)})
			require.NoError(t, err)
			r := v1.Deployment{}
			helm.UnmarshalK8SYaml(t, output, &r)

			if withTolerations {
				require.Len(t, r.Spec.Template.Spec.Tolerations, 1)
				require.Equal(t, r.Spec.Template.Spec.Tolerations[0].Key, values["tolerations[0].key"])
				require.Equal(t, string(r.Spec.Template.Spec.Tolerations[0].Operator), values["tolerations[0].operator"])
				require.Equal(t, string(r.Spec.Template.Spec.Tolerations[0].Effect), values["tolerations[0].effect"])
			} else {
				require.Len(t, r.Spec.Template.Spec.Tolerations, 0)
			}

		})
	}

}

func (s *TemplateGoldenTest) TestPodDisruptionBudget() {

}
