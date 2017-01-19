# OACIS + Jupyter Notebook Image

## What it Gives You

- Jupyter Notebook 4.3.x
- Conda Python 3.x and Python 2.7.x environments
- pandas, matplotlib, scipy, seaborn, scikit-learn, scikit-image, sympy, cython, patsy, statsmodel, cloudpickle, dill, numba, bokeh, vincent, beautifulsoup, xlrd pre-installed
- Unprivileged user `jovyan` (uid=1000, configurable, see options) in group `users` (gid=100) with ownership over `/home/jovyan` and `/opt/conda`
- [tini](https://github.com/krallin/tini) as the container entrypoint and [start-notebook.sh](../base-notebook/start-notebook.sh) as the default command
- A [start-singleuser.sh](../base-notebook/start-singleuser.sh) script useful for running a single-user instance of the Notebook server, as required by JupyterHub
- A [start.sh](../base-notebook/start.sh) script useful for running alternative commands in the container (e.g. `ipython`, `jupyter kernelgateway`, `jupyter lab`)
- Options for HTTPS, password auth, and passwordless `sudo`

## Basic Usage

The following command starts a container with OACIS and the Jupyter Notebook server listening for HTTP connections on port 3000 and 8888, respectively.

```
docker run --name my_oacis -p 3000:3000 -p 8888:8888 -dt oacis/oacis_jupyter
```

## Register a sample simulator

```
docker exec -t -u oacis jupyter_test bash /home/oacis/setup_ns_model.sh
```

It will register a simulator "Nagel_Schreckenberg" to OACIS. The source code of the simulator can be found at [yohm/nagel_schreckenberg_model](https://github.com/yohm/nagel_schreckenberg_model).

