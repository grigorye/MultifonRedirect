#! /bin/sh -xe

supDir="${PWD:?}/sup"

if ${clean:?}
then
	rm -rf build
else
	rm -rf build/*.result
fi

mkdir -p build/fastlane

if ${clean_sup:?}
then
	rm -rf "${supDir:?}"
fi

mkdir -p "${supDir:?}"
cd "${supDir:?}"
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
export PATH="${supDir:?}"/homebrew/bin:"$PATH"
export GEM_HOME="${supDir:?}"/gem/ruby
export PATH="$PATH:${GEM_HOME:?}/bin"
gem install -N bundler
bundle install --deployment --path "${GEM_HOME:?}" --gemfile=../src/Gemfile

cd ../src
export LC_ALL="en_US.UTF-8"
env \
	BUILD_DIR=../build \
	XC_FABRIC_API_KEY="${CRASHLYTICS_API_TOKEN:?}" \
	XC_FABRIC_BUILD_SECRET="${CRASHLYTICS_BUILD_SECRET:?}" \
	CRASHLYTICS_DEBUG=true \
	CRASHLYTICS_EMAILS=cake214@icloud.com \
	GYM_XCARGS='CRASHLYTICS_ENABLED=YES'"${GE_JENKINS_SWIFT_VERSION:+ SWIFT_VERSION=${GE_JENKINS_SWIFT_VERSION:?}}" \
    FL_REPORT_PATH="$PWD/../build/fastlane" \
	FASTLANE_DONT_STORE_PASSWORD=1 \
	MATCH_VERBOSE=1 \
	bundle exec fastlane ios "${lane:?}"
