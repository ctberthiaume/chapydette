FROM continuumio/miniconda3:4.10.3

RUN apt-get update -q \
    && apt-get install -q -y build-essential libgeos-dev libproj-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && conda update -y conda \
    && useradd --create-home --shell /bin/bash chapydette

USER chapydette
WORKDIR /home/chapydette/

# Configure conda, default env, and deps in their own layers
RUN bash -c ". /opt/conda/etc/profile.d/conda.sh \
    && conda create -y -n chpy python=3.7 cython numpy pandas click pyarrow nb_conda numba jupyter matplotlib scipy scikit-learn netcdf4 cartopy seaborn \
    && conda install -y -n chpy pytorch torchvision cpuonly faiss-cpu -c pytorch \
    && conda install -y -n chpy -c conda-forge gsw \
    && conda clean --all"
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate chpy" >> ~/.bashrc

COPY --chown=chapydette:chapydette ./chapydette ./src/chapydette
COPY --chown=chapydette:chapydette ./setup.py ./readme.md ./src/
COPY --chown=chapydette:chapydette ./entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=chapydette:chapydette --chmod=0755 ./findchangepoints /usr/local/bin/findchangepoints

RUN bash -c ". /opt/conda/etc/profile.d/conda.sh && conda activate chpy && cd ./src && python setup.py install"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/local/bin/findchangepoints"]
