# epi-workshop-atac-chip-processing
Pipeline for NBIS epigenomics workshop ATAC and ChIP data preparation


## Usage

### Rackham

```
export NXF_HOME="/sw/courses/epigenomics/2025/atacseq/nxf"
export NXF_SINGULARITY_CACHEDIR="/sw/courses/epigenomics/2025/atacseq/pipeline/containers"

pipelineDir="/sw/courses/epigenomics/2025/atacseq/pipeline/epi-workshop-atac-chip-processing"

module load java/OpenJDK_22+36

${NXF_HOME}/nextflow run "${pipelineDir}/atac-chip-processing.nf" \
        -c "${pipelineDir}/configs/rackham.config" -c atac-chip-proc.config \
        -profile rackham
```
