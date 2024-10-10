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

type TemplateConsole struct {
	Base
}

func TestConsole(t *testing.T) {
	// could be ldflags, but does not seem to work with go test ./... -ldflags "-X tests/helm/suite_test.ChartPath=../../charts/cloudprem"
	if chartDirFromEnv := os.Getenv("CHART_DIR"); chartDirFromEnv != "" {
		chartDir = chartDirFromEnv
	}

	chartPath, err := filepath.Abs(filepath.Join(chartDir, "console"))
	require.NoError(t, err)

	chartTest := &TemplateConsole{
		Base: Base{
			ChartPath: chartPath,
			ChartDir:  chartDir,
			Release:   releaseName,
			Name:      "console",
			Namespace: "ccsm-helm-" + strings.ToLower(random.UniqueId()),
			setValues: map[string]string{},
		},
	}

	suite.Run(t, chartTest)
}

func (s *TemplateConsole) TestCookieEncryptionKey() {
	t := s.T()
	t.Parallel()

	templateName := "deployment.yaml"

	for _, withEncryptioNKey := range []bool{true, false} {
		t.Run(fmt.Sprintf("%s-with-encryption-secret-%s", t.Name(), strconv.FormatBool(withEncryptioNKey)), func(t *testing.T) {
			t.Parallel()
			var values map[string]string
			if withEncryptioNKey {
				values = map[string]string{
					"global.platform.cookie.existingSecret":           uuid.NewString(),
					"global.platform.cookie.secretKeys.encryptionKey": uuid.NewString(),
				}
			} else {
				values = map[string]string{
					"global.platform.cookie.encryptionKey": uuid.NewString(),
				}
			}
			options := s.Options(
				WithValues(values),
			)
			output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("templates/%s", templateName)})
			require.NoError(t, err)
			r := v1.Deployment{}
			helm.UnmarshalK8SYaml(t, output, &r)
			if !withEncryptioNKey {
				require.Contains(t, r.Spec.Template.Spec.Containers[0].Env, coreV1.EnvVar{
					Name:  "ENCRYPTION_KEY",
					Value: values["global.platform.cookie.encryptionKey"],
				})

				return
			}
			require.Contains(t, r.Spec.Template.Spec.Containers[0].Env, coreV1.EnvVar{
				Name: "ENCRYPTION_KEY",
				ValueFrom: &coreV1.EnvVarSource{
					SecretKeyRef: &coreV1.SecretKeySelector{
						LocalObjectReference: coreV1.LocalObjectReference{
							Name: values["global.platform.cookie.existingSecret"],
						},
						Key: values["global.platform.cookie.secretKeys.encryptionKey"],
					},
				},
			})
		})
	}

}
