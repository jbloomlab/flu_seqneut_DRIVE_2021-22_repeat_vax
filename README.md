# Sequencing-based neutralization assays of 2021-2022 DRIVE samples versus H1N1 influenza libraries

Sequencing-based neutralization to analyze titers of human serum samples from the DRIVE cohort against H1N1 virus after vaccination of individuals with one or two prior vaccinations.

Study by [Loes et al (2024)](https://doi.org/10.1101/2024.03.08.584176).

The final titers for each serum-virus pair are in [results/aggregated_titers/titers_DRIVE.csv](results/aggregated_titers/titers_DRIVE.csv).
The [./results/](results) also contains additional more detailed files with the per-viral-barcode counts for each sample, the fraction infectivities used to fit the neutralization curves, and details on the curve fits and titers for each individual replicate.

HTML documentation of analysis steps is rendered via GitHub Pages at [https://jbloomlab.github.io/flu_seqneut_DRIVE_2021-22_repeat_vax/](https://jbloomlab.github.io/flu_seqneut_DRIVE_2021-22_repeat_vax/)

This repository contains an analysis of the data using [seqneut-pipeline](https://github.com/jbloomlab/seqneut-pipeline).
Briefly, that pipeline is a submodule of this analysis.
The configuration for the analysis is in [config.yml](config.yml), the input data are in [./data/](data), the analysis itself is run by `snakemake` using [Snakefile](Snakefile), the results are placed in [./results/](results), and HTML rendering of results is in [./docs/](docs).

See [seqneut-pipeline](https://github.com/jbloomlab/seqneut-pipeline) for more description of how the pipeline works.
In addition to running the pipeline itself, [Snakefile](Snakefile) also contains a few extra rules that run the Jupyter notebooks in [./notebooks/](notebooks) to create some additional plots.
To run the pipeline, build the `seqneut-pipeline` conda environment in [seqneut-pipeline/environment.yml](seqneut-pipeline/environment.yml).
Then run the pipeline using:

    snakemake -j <n_jobs> --software-deployment-method conda

To run on the Hutch cluster, you can use the Bash scripts [run_Hutch_cluster.bash](run_Hutch_cluster.bash).
