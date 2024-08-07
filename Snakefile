"""Top-level ``snakemake`` file that runs analysis."""

#import required processing packages
import pandas as pd
from os.path import join

configfile: "config.yml"

include: "seqneut-pipeline/seqneut-pipeline.smk"

#input files for initial titer pooling analysis
librarytiteringbarcodes_runs = pd.read_csv(config["initial_pooling"])
samples_initialpool = librarytiteringbarcodes_runs["well"].unique().tolist()

rule all:
    input:
        seqneut_pipeline_outputs,  # outputs from pipeline
        "results/plots_for_paper/titers_serawithgap_rotated.html",
        "results/plots_for_paper/plot_specific_sera/curves.pdf",
        expand(join("results/librarytiterbarcodecounts","counts", "{sample}_counts.csv"),sample=samples_initialpool),
        "results/librarytiterbarcodecounts/repoolingstrains_volumetoadd.csv",

rule count_barcodes_initialpool:
    """Count barcodes for each sample."""
    input:
        fastq=lambda wildcards: librarytiteringbarcodes_runs.set_index("well").at[wildcards.sample, "fastq"],
        viral_library=config['viral_libraries']['pdmH1N1_lib2023_loes'],
        neut_standard_set=config['neut_standard_sets']['loes2023'],
    output:
        counts=join("results/librarytiterbarcodecounts", "counts", "{sample}_counts.csv"),
        invalid=join("results/librarytiterbarcodecounts", "invalid_counts", "{sample}_invalid.csv"),
        fates=join("results/librarytiterbarcodecounts", "fates", "{sample}_fates.csv"),
    params:
        illumina_barcode_parser_params=config["illumina_barcode_parser_params"],
    conda:
        "seqneut-pipeline/envs/count_barcodes.yml"
    log:
        "results/logs/count_barcodes_{sample}.txt",
    script:
        "seqneut-pipeline/scripts/count_barcodes.py"

rule process_barcoderatios:
    """Count barcodes for each sample."""
    input:
        viral_library=config['viral_libraries']['pdmH1N1_lib2023_loes'],
        neut_standard_set=config['neut_standard_sets']['loes2023'],
        initialpool_metadata = "data/initialpool/2022_pdmH1N1library_initialPool.csv",
        initial_pool_counts=expand(
            'results/librarytiterbarcodecounts/counts/{sample}_counts.csv',
            sample=samples_initialpool,
        ),
        initial_pool_fates=expand(
            'results/librarytiterbarcodecounts/fates/{sample}_fates.csv',
            sample=samples_initialpool,
        ),
        repooledlibraryfile = "results/barcode_counts/plate1_none-1.csv",
    output:
        strainpooling = "results/librarytiterbarcodecounts/repoolingstrains_volumetoadd.csv",
        equalvolume_plot = "results/librarytiterbarcodecounts/diffinrepresentation_equalvolumerepool.svg",
        repool_plot = "results/librarytiterbarcodecounts/diffinrepresentation_afterrepool.svg",
    log:
        notebook="results/librarytiterbarcodecounts/process_barcoderatios.ipynb",
    conda:
        "seqneut-pipeline/environment.yml"
    notebook:
        "notebooks/process_barcoderatios.py.ipynb"

rule plot_specific_sera:
    """Plot curves for a few specific sera."""
    input:
        curvefits_pickle="results/aggregated_titers/curvefits_DRIVE.pickle",
    output:
        plot_pdf="results/plots_for_paper/plot_specific_sera/curves.pdf",
    log:
        notebook="results/plots_for_paper/plot_specific_sera/plot_specific_sera.ipynb",
    conda:
        "seqneut-pipeline/environment.yml"
    notebook:
        "notebooks/plot_specific_sera.py.ipynb"

rule summarize_titers:
    """Make titer plots for paper."""
    input:
        input_titers="results/aggregated_titers/titers_DRIVE.csv",
        viral_strain_plot_order=config["viral_strain_plot_order"],
        sample_metadata_file="data/sample_metadata_forplots.csv",
        HAI_titers_file="data/DRIVE_HAI_titers_Hawaii_Y2_H1N1.csv"
    output:
        titers_chart_html="results/plots_for_paper/titers_by_day.html",
        titers_chart_1xVax_html="results/plots_for_paper/titers_1xVax.html",
        titers_chart_2xVax_html="results/plots_for_paper/titers_2xVax.html",
        titers_chart_selectedpeople_html="results/plots_for_paper/titers_selectedpeople.html",
        titers_chart_median_w182_html="results/plots_for_paper/titers_median_w182.html",
        titers_chart_median_all_html="results/plots_for_paper/titers_median_all.html",
        titers_chart_foldchange_html="results/plots_for_paper/titers_foldchange.html",
        titers_chart_splitbygroup_w182_html="results/plots_for_paper/titers_splitbygroup_w182.html",
        titers_chart_splitbygroup_all_html="results/plots_for_paper/titers_splitbygroup_all.html",
        titers_chart_selectedserum_rotated_html="results/plots_for_paper/titers_selectedserum_rotated.html",
        titers_chart_serawithgap_rotated_html="results/plots_for_paper/titers_serawithgap_rotated.html"
    log:
        notebook="results/plots_for_paper/summarize_titers.ipynb",
    notebook:
        "notebooks/summarize_titers.py.ipynb"
