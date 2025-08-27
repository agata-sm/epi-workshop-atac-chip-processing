nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process MAP_READS_GENOME {

	label 'error_retry'
    label 'process_high'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true


	container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'


    input:
    //tuple val(pair_id), path(r1), path(r2), path(idx_bowtie2_ch)
    tuple val(pair_id), path(r1), path(r2)
    path idx_bowtie2_ch
    path genomeFasta


    output:
    tuple val(pair_id), path("${pair_id}.sorted.bowtie2.bam"), path("${pair_id}.sorted.bowtie2.bam.bai"), emit: mappedPE_ch

    script:

    def args = task.ext.args ?: ''


    """
    bowtie2 -p ${task.cpus} ${args} -x bowtie2/${genomeFasta.baseName} -1 ${r1} -2 ${r2}  | samtools view -hbo ${pair_id}.mapped.bowtie2.bam - 
    
    samtools sort -T ${pair_id} -o ${pair_id}.sorted.bowtie2.bam ${pair_id}.mapped.bowtie2.bam
    samtools index ${pair_id}.sorted.bowtie2.bam -o ${pair_id}.sorted.bowtie2.bam.bai
    """

}

