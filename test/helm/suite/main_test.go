package suite_test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/go-commons/errors"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/stretchr/testify/suite"
)

var (
	releaseName   = "helm-basic"
	chartDir      = "../../../charts/"
	mainChart     = "cloudprem"
	plaformCharts = []string{"portal", "console", "membership"}
	charts        = []string{"portal", "console", "stargate"}
)

type Base struct {
	suite.Suite
	Name      string
	ChartDir  string
	ChartPath string
	Release   string
	Namespace string
	setValues map[string]string
}

type helmOpt func(*helm.Options) *helm.Options

func WithValues(values map[string]string) helmOpt {
	return func(opts *helm.Options) *helm.Options {
		for k, v := range values {
			opts.SetValues[k] = v
		}
		return opts
	}
}

func WithDefaultValues(base *Base) helmOpt {
	return func(opts *helm.Options) *helm.Options {
		WithValues(base.setValues)(opts)
		return opts
	}
}

func (s *Base) setupSuite(t *testing.T) error {
	if os.Getenv("NO_UPDATE") == "true" {
		return nil
	}
	if _, err := helm.RunHelmCommandAndGetStdOutE(t, s.Options(), "dependency", "update", s.ChartPath); err != nil {
		return errors.WithStackTrace(err)
	}
	return nil
}

func (s *Base) Options(helmOpts ...helmOpt) *helm.Options {
	// Find a way to read the Chart.yaml to add the repository
	opts := &helm.Options{
		KubectlOptions: k8s.NewKubectlOptions("", "", s.Namespace),
		// Need to add all the repositories
		// BuildDependencies: true,
		SetValues: map[string]string{},
	}
	WithDefaultValues(s)(opts)

	for _, opt := range helmOpts {
		opts = opt(opts)
	}

	opts.Logger = logger.Discard
	if testing.Verbose() {
		opts.Logger = logger.TestingT
	}

	return opts
}

type TemplateChart struct {
	TemplateGoldenTest
}
