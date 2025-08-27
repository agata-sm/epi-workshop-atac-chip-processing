// filt_bam


nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_FILT {

	label 'error_retry'
    label 'process_medium'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true

	container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'

    input:
    tuple val(pair_id), path(mapped_bam), path(mapped_bam_idx)
    path(noblcklst_bed)


    output:
    tuple val(pair_id), path("${pair_id}.filt.bam"),path("${pair_id}.filt.bam.bai"), emit: bam_filt_ch

    script:

    def args = task.ext.args ?: ''


    """
 	samtools view ${args} -hbo - ${mapped_bam} | samtools -M -L ${noblcklst_bed} -hbo ${pair_id}.filt.bam -

    samtools index ${pair_id}.filt.bam -o ${pair_id}.filt.bam.bai
    samtools idxstats ${pair_id}.filt.bam  >${pair_id}.filt.bam.idxstats
    """

}

