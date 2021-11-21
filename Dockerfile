FROM python:3.9-slim-bullseye

# Copy minimal set of SQLFluff install files
# into their own folder for easier debugging.
WORKDIR /app

ENV VIRTUAL_ENV .venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH $VIRTUAL_ENV/bin:$PATH
RUN pip install --upgrade pip setuptools wheel

COPY setup.py .
COPY src/sqlfluff/config.ini ./src/sqlfluff/config.ini
COPY README.md .

# Assumes containerized version of python does not have special dependencies in setup.py
# Note: I might advocate that there be a seperate requirements.txt with fixed dependency versions
#       just for the docker container. i.e., == only, no >= etc. That way the container serves as
#       a specific reference implementation that is "guaranteed" to function as intended. 
RUN python setup.py egg_info
RUN grep -v -e dataclasses -e '\[:python_version' src/sqlfluff.egg-info/requires.txt > requires.txt
RUN pip install -r requires.txt

COPY src ./src
COPY MANIFEST.in .

RUN pip install --no-dependencies .

# Switch to non-root user.
USER 5000

# Set SQLFluff command as entry point for image.
ENTRYPOINT ["sqlfluff"]
CMD ["--help"]
