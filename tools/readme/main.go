package main

import (
	"context"
	"fmt"
	"html/template"
	"os"
	"path/filepath"

	sprig "github.com/Masterminds/sprig/v3"
	yaml "github.com/goccy/go-yaml"
	"github.com/spf13/cobra"
)

var (
	assetsPatternFlag    string = "assets-dir"
	templateFileNameFlag string = "template-file"
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

type values struct{}

func listCharts(chartDir string) ([]chart, error) {
	pwd, err := os.Getwd()
	if err != nil {
		return nil, err
	}

	dir, err := os.ReadDir(filepath.Join(pwd, chartDir))
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

			if _, err := os.Stat(filepath.Join(pwd, chartDir, entry.Name(), "Chart.yaml")); err == nil {
				hasChartYaml = true

				b, err := os.ReadFile(filepath.Join(pwd, chartDir, entry.Name(), "Chart.yaml"))
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

	assetPattern := cmd.Flag(assetsPatternFlag).Value.String()
	if assetPattern == "" {
		return fmt.Errorf("assets-pattern is required")
	}

	fileName := cmd.Flag(templateFileNameFlag).Value.String()
	if fileName == "" {
		return fmt.Errorf("template-file-name is required")
	}

	funcMaps := sprig.FuncMap()

	funcMaps["listCharts"] = listCharts

	funcMaps["readFile"] = os.ReadFile

	funcMaps["fromYaml"] = func(data []byte) map[string]interface{} {
		values := make(map[string]interface{})
		if err := yaml.Unmarshal(data, &values); err != nil {
			panic(err)
		}

		return values
	}

	funcMaps["toHTML"] = func(s string) template.HTML {
		return template.HTML(s)
	}

	funcMaps["toYaml"] = func(v interface{}) string {
		b, err := yaml.Marshal(v)
		if err != nil {
			panic(err)
		}
		return string(b)
	}

	tmpl, err := template.
		New(fileName).
		Funcs(funcMaps).
		ParseGlob(assetPattern)
	if err != nil {
		return err
	}
	return tmpl.Execute(cmd.OutOrStdout(), values{})
}

func NewRootCommand() *cobra.Command {
	root := &cobra.Command{
		Use:  "readme",
		Long: "readme is a tool to generate README.md file",
		RunE: runE,
	}

	root.Flags().String(assetsPatternFlag, "../../assets/templates/*.tpl", "assets pattern")
	root.Flags().String(templateFileNameFlag, "readme.tpl", "template file name")

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
