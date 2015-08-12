# xsub

A wrapper for job schedulers.
Job schedulers used in HPCs, such as Torque, often have its own I/O format.
Users have to change their scripts to conform with its dialect.
This is a wrapper script to absorb the difference.
This script is intended to be used by [OACIS](https://github.com/crest-cassia/oacis).

Although only a few types of schedulers are currently supported, you can extend this in order to fit your schedulers.

## Installation

- Install Ruby 1.9 or later.
  - We recommend using [rbenv](https://github.com/sstephenson/rbenv) to install Ruby.
  - In some environments such as fx10, it does not work with Ruby 2.1. In such case, please use 2.0 or 1.9.

- Clone this repository

  ```
  git clone https://github.com/crest-cassia/xsub.git
  ```

- set `PATH` and `XSUB_TYPE` environment variables in your ~/.bashrc (or ~/.zshrc)
  - set `PATH` so as to include the bin directory of xsub. Then you can use `xsub`, `xstat`, and `xdel` commands.
  - set XSUB_TYPE to be either "none", "torque", "fx10", or "k", depending on the scheduler you are using.
  - If you run xsub from OACIS, please set these variables in .bashrc even if your login shell is zsh. This is because OACIS execute xsub on bash.

  ```sh:.bashrc
  export PATH="$HOME/xsub/bin:$PATH"
  export XSUB_TYPE="torque"
  ```

## Usage

Three commands **xsub**, **xstat**, and **xdel** are provided.
These correspond to qsub, qstat, and qdel of Torque.

It prints JSON to the standard output so that the outputs are easily handled by other programs.

### xsub

submit a job to a scheduler

- **usage**: `xsub {job_script}`
- **options**:
  - "-d WORKDIR" : set working directory
    - when the job is executed, the current directory is set to this working directory.
    - if the directory does not exist, a new directory is created.
  - "-p PARAMETERS" : set parameters required to submit a job
  - "-t" : show parameters to submit a job in JSON format. Job is not submitted.
  - "-l" : Path to the log file directory.
    - If this option is not given, the logs are printed in the current directory.
    - If the directory does not exist, a new directory is created.

- **output format**:
  - when "-t" option is given, it prints JSON as follows.
    - it must have a "parameters" field.
    - Each parameter has "description", "default", and "format" fields.
      - "description" and "format" fields are optional.
      - format is given as a regular expression. If the given parameter does not match the format, xsub fails.

  ```json
  {
    "parameters": {
      "mpi_procs": {
        "description": "MPI process",
        "default": 1,
        "format": "^[1-9]\\d*$"
      },
      "omp_threads": {
        "description": "OMP threads",
        "default": 1,
        "format": "^[1-9]\\d*$"
      },
      "ppn": {
        "description": "Process per node",
        "default": 1,
        "format": "^[1-9]\\d*$"
      },
      "elapsed": {
        "description": "Limit on elapsed time",
        "default": "1:00:00",
        "format": "^\\d+:\\d{2}:\\d{2}$"
      }
    }
  }
  ```

  - when job is submitted, the output format looks like the following.
    - it must have a key "job_id". The value of job_id can be either a number or a string.
  ```json
  {
    "job_id": 21507
  }
  ```
  - When it succeeds, return code is zero. When it fails, return code is non-zero.

- **example**

```sh
xsub job.sh -d work_dir -l log_dir -p '{"mpi_procs":3,"omp_threads":4,"ppn":4,"elapsed":"2:00:00"}'
```

### xstat

show a status of a job

- **usage**: `xstat {job_id}` or `xstat`
  - when "job_id" is given, show the status of the job
  - when "job_id" is not given, show current the status of the scheduler

- **output format**:
  - when "job_id" is given, it prints JSON as follows.
  ```json
  {
    "status": "running",
  }
  ```
    - status field takes either "queued", "running", or "finished".
      - "queued" means the job is in queue.
      - "running" means the job is running.
      - "finished" means the job is finished or the job is not found.
    - "log_paths" fileds has an array of paths to scheduler log files.
- when job_id is not given, the output format is not defined.
    - it usually prints the output of `qsub` command.

- **example**

```sh
xstat 12345   # => { "status": "queued" }
```

### xdel

delete a job

- **usage**: `xdel {job_id}`
  - cancel the specified job
    - if the job finished successfully, return code is zero.
    - if the job is not found, it returns non-zero.
  - output format is not defined.

## Supported Schedulers

List of available schedulers.

- **none**
  - If you are not using a scheduler, please use this. The command is executed as a usual process.
- **torque**
  - [Torque](http://www.adaptivecomputing.com/products/open-source/torque/)
  - `qsub`, `qstat`, `qdel` commands are used.
- **fx10**
  - a scheduler for fx10.
  - `pjsub`, `pjstat`, `pjdel` commands are used.
- **k**
  - a scheduler for the k-computer.
  - `pjsub`, `pjstat`, `pjdel` commands are used.
  - Files in the work_dir are staged-in.
  - Files created in the `work_dir` are staged-out.

## Extending

- If your scheduler is not supported, you can extend xsub by yourself.
  - Fork the repository.
  - Add your file to `lib/xsub/schedulers` and edit `lib/xsub.rb` properly.
    - Because this library is small, you can read the whole source code easily.
    - Please make sure that the output format is same as the existing one so that it can be used by OACIS.
- If you are not familiar with Ruby, please contact us.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
