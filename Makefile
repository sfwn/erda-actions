GitBranch=$(shell git rev-parse --abbrev-ref HEAD)
GitCommit=$(shell git rev-parse --short HEAD)
Date=$(shell date +"%Y%m%d")
BuildTime=$(shell date '+%Y-%m-%d %T%z')
Registry="registry.cn-hangzhou.aliyuncs.com/dice"

.ONESHELL:
echo \
custom-script java-agent \
git-checkout assert jsonparse redis-cli mysql-cli git-push release dice dice-deploy dice-deploy-addon dice-deploy-service dice-deploy-domain dice-deploy-release dice-deploy-redeploy dice-deploy-rollback \
buildpack buildpack-aliyun java java-build js js-build manual-review js-deploy dockerfile docker-push php gitbook js-script\
sonar integration-test unit-test api-test  java-lint testplan java-dependency-check golang java-unit android ios mobile-template lib-publish mobile-publish java-deploy \
oss-upload delete-nodes ess-info loop api-register api-publish publish-api-asset mysqldump dice-version-archive:

	@set -eo pipefail

	@echo start make action: $@

	version="$${VERSION}"
	if [[ "$${version}" == "" ]]; then
		if [[ "`ls -l actions/$@ | wc -l | tr -d ' '`" != "2" ]]; then
			echo Multi version [$$(echo `ls actions/$@` | sed 's/ /, /g')] detected, which version you want to make? \
				 specify by env: VERSION=1.0
			exit 1
		fi
		version=`ls actions/$@`
		echo Auto select the only version: $${version}
	fi

	@echo use version: $${version}

	@dockerfile="actions/$@/$${version}/Dockerfile"
	@echo expected Dockerfile: $${dockerfile}
	if [[ ! -f $${dockerfile} ]]; then echo "expected Dockerfile not exist, stop." && exit 1; fi

	image="$(Registry)/$@-action:$(Date)-${GitCommit}"
	@echo image=$${image}

	dockerbuild="docker build . -f $${dockerfile} -t $${image} \
				 --label 'branch=$(GitBranch)' --label 'commit=$(GitCommit)' --label 'build-time=$(BuildTime)'"
	# --pull
	if [[ $@ == "java-dependency-check" ]]; then dockerbuild="$${dockerbuild} --pull"; fi
	# --no-cache
	if [[ $@ == "buildpack" || $@ == "java" || $@ == "java-build" || $@ == "java-agent" ]]; then
		dockerbuild="$${dockerbuild} --no-cache"
	fi
	@echo $${dockerbuild}
	eval "$${dockerbuild}"

	docker push $${image}

.ONESHELL:
sonarqube:

	@set -eo pipefail

	@echo start make $@

	version="$${VERSION}"
	sonarDir="actions/sonar/1.0"
	if [[ "$${version}" == "" ]]; then
		if [[ "`ls -l "$${sonarDir}/$@" | wc -l | tr -d ' '`" != "2" ]]; then
			echo Multi version [$$(echo `ls $${sonarDir}/$@` | sed 's/ /, /g')] detected, which version you want to make? \
				 specify by env: VERSION=1.0
			exit 1
		fi
		version=`ls $${sonarDir}/$@`
		echo Auto select the only version: $${version}
	fi

	@echo use version: $${version}
	cd actions/sonar/1.0/sonarqube/$${version}
	docker build . -t registry.cn-hangzhou.aliyuncs.com/dice-third-party/sonar:$${version} -f Dockerfile
