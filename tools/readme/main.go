package main

import (
	"context"
	"fmt"
	"html/template"
	"os"

	"github.com/Masterminds/sprig/v3"
	"github.com/goccy/go-yaml"
	"github.com/spf13/cobra"
)

var (
	chartDirFlag         string = "chart-dir"
	assetsPatternFlag    string = "assets-dir"
	templatefileNameFlag string = "template-file"
)

type chart struct {
	Name         string   `yaml:"name"`
	Description  string   `yaml:"description"`
	AppVersion   string   `yaml:"appVersion"`
	Version      string   `yaml:"version"`
	KubeVersion  string   `yaml:"kubeVersion"`
	Sources      []string `yaml:"sources"`
	Dependencies []struct {
		Name       string `yaml:"name"`
		Version    string `yaml:"version"`
		Repository string `yaml:"repository"`
	}
}

type values struct {
	Charts []chart
}

func listCharts(chartDir string) ([]chart, error) {
	dir, err := os.ReadDir(chartDir)
	if err != nil {
		return nil, err
	}

	var charts []chart
	for _, entry := range dir {
		if entry.IsDir() {
			var (
				hasChartYaml bool
				ct           chart
			)

			if _, err := os.Stat(fmt.Sprintf("%s/%s/Chart.yaml", chartDir, entry.Name())); err == nil {
				hasChartYaml = true

				b, err := os.ReadFile(fmt.Sprintf("%s/%s/Chart.yaml", chartDir, entry.Name()))
				if err != nil {
					return nil, err
				}

				if err := yaml.Unmarshal(b, &ct); err != nil {
					return nil, err
				}

			}
			if !hasChartYaml {
				continue
			}

			charts = append(charts, ct)
		}
	}

	return charts, nil
}

func runE(cmd *cobra.Command, args []string) error {

	chartDir := cmd.Flag(chartDirFlag).Value.String()
	if chartDir == "" {
		return fmt.Errorf("chart-dir is required")
	}

	assetPattern := cmd.Flag(assetsPatternFlag).Value.String()
	if assetPattern == "" {
		return fmt.Errorf("assets-pattern is required")
	}

	fileName := cmd.Flag(templatefileNameFlag).Value.String()
	if fileName == "" {
		return fmt.Errorf("template-file-name is required")
	}

	charts, err := listCharts(chartDir)
	if err != nil {
		return err
	}
	tmpl, err := template.
		New(fileName).
		Funcs(sprig.FuncMap()).
		ParseGlob(assetPattern)
	if err != nil {
		return err
	}
	return tmpl.Execute(cmd.OutOrStdout(), &values{
		Charts: charts,
	})
}

func NewRootCommand() *cobra.Command {
	root := &cobra.Command{
		Use:  "readme",
		Long: "readme is a tool to generate README.md file",
		RunE: runE,
	}

	root.Flags().String(chartDirFlag, "../../charts", "chart directory")
	root.Flags().String(assetsPatternFlag, "./assets/*.tpl", "assets pattern")
	root.Flags().String(templatefileNameFlag, "readme.tpl", "template file name")

	return root
}

func main() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("Recovered in f", r)
			os.Exit(1)
		}
	}()

	if err := NewRootCommand().ExecuteContext(context.TODO()); err != nil {
		panic(err)
	}
}
