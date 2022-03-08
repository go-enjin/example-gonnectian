// Copyright (c) 2022  The Go-Enjin Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"fmt"
	"os"

	"github.com/go-enjin/be"
	"github.com/go-enjin/be/features/database"
	"github.com/go-enjin/third_party/features/atlassian"
)

func main() {
	homepage := `
<h2>Example Content</h2>
<p>Demonstrating adding content as a plain string with no front-matter metadata.</p>
<p>This page is publicly accessible.</p>
`
	tmpl := `+++
Format = "tmpl"
Layout = "atlassian-connect"
DataOptions = "sizeToParent:true"
+++
<p>This content is an html/template and this string should contain
the value of a context variable set at compile-time: "{{ .CustomVariable }}".</p>
<p>This page is only accessible from an installed Jira plugin while the user is logged in.</p>
`
	enjin := be.New().
		AddThemes("themes").
		SetTheme("custom-theme").
		Set("CustomVariable", "not-empty").
		AddPageFromString("/", homepage).
		AddFeature(database.New().Make()).
		AddFeature(
			atlassian.New().
				ProfileBaseRoute("v1").
				AddGeneralPageFromString(
					"example",
					"/example",
					"Example Page",
					"/gopher.png",
					tmpl,
				).
				AddDashboardItemFromString(
					"example-item",
					"Example Dashboard Item",
					"/gopher.png",
					"Example description of an example dashboard item",
					"/tmpl",
					tmpl,
				).
				Make(),
		).
		Build()
	if err := enjin.Run(os.Args); err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
}