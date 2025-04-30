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
)

type TemplatePlatfromTest struct {
	Base
}

func TestCloudprem(t *testing.T) {
	if chartDirFromEnv := os.Getenv("CHART_DIR"); chartDirFromEnv != "" {
		chartDir = chartDirFromEnv
	}

	chartPath, err := filepath.Abs(filepath.Join(chartDir, mainChart))
	require.NoError(t, err)

	chartTest := &TemplatePlatfromTest{
		Base: Base{
			ChartPath: chartPath,
			ChartDir:  chartDir,
			Release:   releaseName,
			Name:      "cloudprem",
			Namespace: "ccsm-helm-" + strings.ToLower(random.UniqueId()),
			setValues: map[string]string{},
		},
	}

	// Update deps
	for _, app := range plaformCharts {
		chartPath, err := filepath.Abs(filepath.Join(chartDir, app))
		require.NoError(t, err)

		chart := &TemplatePlatfromTest{
			Base: Base{
				ChartPath: chartPath,
				ChartDir:  chartDir,
				Release:   releaseName,
				Name:      app,
				Namespace: "ccsm-helm-" + strings.ToLower(random.UniqueId()),
				setValues: map[string]string{},
			},
		}
		require.NoError(t, chart.setupSuite(t))
	}

	// Then update the main chart deps
	require.NoError(t, chartTest.setupSuite(t))
	suite.Run(t, chartTest)
}
func (s *TemplatePlatfromTest) TestAppEnabled() {
	t := s.T()
	t.Parallel()

	for _, app := range plaformCharts {
		appDir := fmt.Sprint(s.ChartDir + app + "/templates")
		dirEntries, err := os.ReadDir(appDir)
		require.NoError(t, err)
		templateNames := []string{}
		for _, dirEntry := range dirEntries {
			if strings.HasSuffix(dirEntry.Name(), ".yaml") {
				templateNames = append(templateNames, dirEntry.Name())
			}
		}

		for _, templateName := range templateNames {
			for _, enabled := range []bool{true, false} {
				t.Run(fmt.Sprintf("app-%s-%s-enabled-%s", app, templateName, strconv.FormatBool(enabled)), func(t *testing.T) {
					t.Parallel()
					values := make(map[string]string, 0)

					// service
					switch templateName {
					case "hpa.yaml":
						values["autoscaling.enabled"] = "true"
					case "ingress.yaml":
						values["ingress.enabled"] = "true"
					case "pdp.yaml":
						values["podDisruptionBudget.enabled"] = "true"
					case "cronjob-gc.yaml":
						values["config.job.garbageCollector.enabled"] = "true"
					case "cronjob-stack-lifeycle.yaml":
						values["config.job.stackLifeCycle.enabled"] = "true"
						values["feature.managedStacks"] = "false"
					}
					options := s.Options()
					for k, v := range values {
						options.SetValues[fmt.Sprintf("%s.%s", app, k)] = v
					}

					// global
					switch templateName {
					case "tgb.yaml":
						options.SetValues["global.aws.elb"] = "true"
					case "cronjob-stack-lifeycle.yaml":
						options.SetValues["global.nats.enabled"] = "true"
					}

					options.SetValues[fmt.Sprintf("global.platform.%s.enabled", app)] = strconv.FormatBool(enabled)
					output, err := helm.RenderTemplateE(t, options, s.ChartPath, s.Release, []string{fmt.Sprintf("charts/%s/templates/%s", app, templateName)})
					if enabled {
						require.NoError(t, err)
						require.NotEmpty(t, output)
					} else {
						require.Error(t, err)
					}
				})
			}
		}
	}
}
