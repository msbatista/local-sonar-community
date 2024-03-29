# Copyright  2021 Marcelo Silva Batista, silvabatistamarcelo@gmail.com

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#! /bin/bash

SONAR_HOST=http://localhost:9000
SONAR_LOGIN=6a607dda1d1ac043b51061f4c54588cb5d9bbed2
SONAR_PROJECT_KEY=my-project-key-api

PULL_REQUEST_BRANCH=develop 
PULL_REQUEST_BASE=master
PULL_REQUEST_KEY=1

PROVIDER=vsts
PROJECT=my-super-project
INSTANCE_URL=https://dev.azure.com/my-super-organization
RESPOSITORY=my-repository

COVERAGE_REPORT_DIR=MyProject.UnitTests

COVERAGE_EXCLUSIONS="**Startup*.cs,
**Program*.cs,
**.json,
**Test*.cs,
MyProject.UnitTests/**,
MyProject.Infrastructure/Migrations/**,
**Exception*.cs,
.env,
.iodine/**,
.devecontainer/**,
.vscode/**"

EXCLUSIONS="**Startup*.cs,
**Program*.cs,
**.json,
**Test*.cs,
MyProject.UnitTests/**,
MyProject.Infrastructure/Migrations/**,
.env,
.iodine/**,
.devecontainer/**,
.vscode/**"

echo "-------------------------------------"
echo "  Installing dotnet-sonarscanner...  "
echo "-------------------------------------"
if [ ! -f "$HOME/.dotnet/tools/dotnet-sonarscanner" ]; then
    echo "dotnet-sonarscanner not detected. Installing resource..."
    dotnet tool install --global dotnet-sonarscanner
fi


if [ "$PATH" != *"$HOME/.dotnet/tools"* ]; then
    echo "Appending $HOME/.dotnet/tools to PATH variable..."
    export PATH="$PATH:$HOME/.dotnet/tools"
fi

echo "--------------------------------------------------------"
echo "    Installing 'coverlet.msbuild' to test project...    "
echo "--------------------------------------------------------"
dotnet add MyProject.UnitTests/MyProject.UnitTests.csproj package coverlet.msbuild

echo "--------------------------------"
echo "   Running automated tests...   "
echo "--------------------------------"
dotnet test MyProject.UnitTests/MyProject.UnitTests.csproj \
    /p:CollectCoverage=true \
    /p:CoverletOutputFormat=opencover

echo "--------------------------------"
echo "  Starting sonar analysis...    "
echo "--------------------------------"
dotnet sonarscanner begin /k:"$SONAR_PROJECT_KEY" \
    /d:sonar.host.url="$SONAR_HOST" \
    /d:sonar.login="$SONAR_LOGIN" \
    /d:sonar.cs.opencover.reportsPaths="$COVERAGE_REPORT_DIR/coverage.opencover.xml" \
    /d:sonar.coverage.exclusions="$COVERAGE_EXCLUSIONS" \
    /d:sonar.exclusions="$EXCLUSIONS" \
    /d:sonar.pullrequest.key="$PULL_REQUEST_KEY" \
    /d:sonar.pullrequest.branch="$PULL_REQUEST_BRANCH" \
    /d:sonar.pullrequest.base="$PULL_REQUEST_BASE" \
    /d:sonar.pullrequest.provider="$PROVIDER" \
    /d:sonar.pullrequest.vsts.project="$PROJECT"
    /d:sonar.pullrequest.vsts.instanceUrl="$INSTANCE_URL" \
    /d:sonar.pullrequest.vsts.respository="$RESPOSITORY"

echo "--------------------------------"
echo "       Building project         "
echo "--------------------------------"
dotnet build MyProject.Api.sln

echo "--------------------------------"
echo "       Finishing analysis"
echo "--------------------------------"
dotnet sonarscanner end /d:sonar.login="$SONAR_LOGIN"