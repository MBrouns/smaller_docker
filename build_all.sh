docker build -f py38.Dockerfile -t sizetest_py38 .
docker build -f py38-alpine.Dockerfile -t sizetest_py38-alpine .
docker build -f py38-alpine-multistage.Dockerfile -t sizetest_py38-alpine-multistage .
docker build -f py38-alpine-compile.Dockerfile -t sizetest_py38-alpine-compile .
docker build -f py38-compile.Dockerfile -t sizetest_py38-compile .
docker build -f py38-slim.Dockerfile -t sizetest_py38-slim .
docker build -f py38-slim-compile.Dockerfile -t sizetest_py38-slim-compile .
docker build -f py38-slim-multistage.Dockerfile -t sizetest_py38-slim-muiltistage .
docker build -f py38-slim-no-cache.Dockerfile -t sizetest_py38-slim-no-cache .

