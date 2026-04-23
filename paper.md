---
title: "neuroSCC: Bridging Simultaneous Confidence Corridors and PET Neuroimaging"
tags:
  - R
  - neuroimaging
  - PET
  - functional data analysis
  - statistical inference
authors:
  - name: Juan A. Arias Lopez
    orcid: 0000-0002-3355-6393
    affiliation: "1, 2"
affiliations:
  - name: Triple Alpha Innovation, S.L.
    index: 1
  - name: Biostatistics and Biomedical Data Science Unit, Universidade de Santiago de Compostela, Spain
    index: 2
date: 2026
bibliography: paper.bib
---

# Summary

`neuroSCC` is an R package for the practical application of Simultaneous Confidence Corridors (SCC) to neuroimaging data. SCC is a recent development in Functional Data Analysis (FDA) [@ramsay2005principal] with strong theoretical properties, but its use with real imaging datasets has been limited by the lack of integrated software support.

This package provides a reproducible workflow that connects raw neuroimaging data to FDA representations, SCC estimation, and performance evaluation. By integrating data processing, statistical inference, and result assessment within a single framework, the package enables the practical use of SCC methods in real neuroimaging studies.

# Statement of need

SCC is a recent statistical development [@Wang2019] that has not yet been incorporated into practical neuroimaging workflows. Existing implementations, such as `ImageSCC`, are primarily methodological and designed to support the mathematical validation of SCC approaches, but do not provide the infrastructure required for applied use on real data.

Applying SCC to neuroimaging requires a sequence of non-trivial steps, including image loading, data restructuring into functional representations, integration with statistical estimation procedures, and post-hoc evaluation against ground truth. In the absence of dedicated tools, carrying out this workflow would require ad hoc scripts and the combination of multiple software environments, making the process time-consuming, error-prone, and difficult to reproduce.

To our knowledge, `neuroSCC` provides the first structured approach to operationalizing SCC in a neuroimaging context. It integrates data preprocessing, functional data construction, SCC estimation, and performance evaluation into a single reproducible workflow, enabling the practical application of SCC techniques to real neuroimaging problems.

# State of the field

Neuroimaging analysis pipelines typically rely on established frameworks such as Statistical Parametric Mapping (SPM) [@SPM] and related tools, as well as R packages for neuroimaging data handling. Packages such as `oro.nifti`, `RNifti`, `neurobase`, and `fslr` provide essential infrastructure for reading, manipulating, and preprocessing imaging data.

While these tools are useful for neuroimaging workflows, they are primarily designed for data handling in classical voxel-wise analysis. They do not support the transformation of imaging data into functional representations required for FDA-based methodologies, nor do they incorporate SCC-based inference.

On the methodological side, FDA provides a general framework for modeling structured data [@ramsay2005principal], and SCC has been introduced as a principled approach for inference over spatial domains [@Wang2019]. However, implementations such as `ImageSCC` operate on abstract functional data and do not provide support for the ingestion and processing of real neuroimaging datasets.

As a result, there is currently no software that bridges neuroimaging workflows with SCC methodology. The `neuroSCC` package addresses this gap by integrating data loading, transformation into FDA representations, SCC estimation, and evaluation within a unified framework, enabling the application of SCC methods to real neuroimaging problems entirely within R.

# Software design

`neuroSCC` is designed as a modular workflow that operationalizes SCC for neuroimaging entirely within R. Its architecture follows the sequence of steps required to move from raw neuroimaging data to statistically interpretable outputs, while keeping the intermediate representations explicit and reproducible.

The workflow begins with data ingestion and restructuring. Neuroimaging files in standard formats such as NIfTI are loaded and converted into structured data representations suitable for downstream analysis. These data are then organized into matrices and transformed into FDA-compatible representations, allowing SCC methods to be applied to imaging data defined over a spatial domain.

Once the functional representation has been constructed, `neuroSCC` supports the preparation of the domain required for SCC estimation, including contour extraction and triangulation-based representations when needed. The package then interfaces with SCC estimation procedures while preserving a workflow centered on neuroimaging data rather than on abstract functional inputs alone.

Beyond estimation, the package provides tools to extract significant regions of change, compare SCC detections with alternative approaches such as SPM, and evaluate performance against ground truth ROI data. This makes it possible to use SCC not only as a methodological construct, but as part of a complete applied workflow for neuroimaging studies and for the visualization and presentation of results. The overall workflow is summarized in Figure 1.

![Overview of the `neuroSCC` workflow, from neuroimaging data ingestion to SCC-based inference and performance evaluation, including comparison with SPM.](paper/workflow.png)

# Research impact statement

`neuroSCC` enables the application of SCC methodology to compare brain activity patterns between groups of neuroimaging scans within a reproducible workflow. In practice, this corresponds to identifying regions with statistically significant differences in activity between cohorts.

The current development is motivated by PET imaging in the context of Alzheimer's disease, where group comparisons of metabolic activity are used to characterize disease-related patterns. This work builds upon previous research exploring SCC-based inference in imaging contexts [@computers] and is further supported by a broader doctoral research framework [@arias2025thesis]. While the present work focuses on PET data, the workflow is not modality-specific and can be extended to other neuroimaging settings in which group-level differences are of interest.

By providing a consistent pipeline for data preparation, SCC estimation, and evaluation, `neuroSCC` lowers the barrier to applying advanced statistical methods in practical neuroimaging studies.

# AI usage disclosure

This manuscript was prepared with the assistance of a large language model (OpenAI, GPT-5.4) for refining the text and improving the English. The author reviewed and validated all content to ensure its accuracy and consistency with the underlying research.

# Acknowledgements

This work was developed as part of the Ph.D. thesis of the author at the Universidade de Santiago de Compostela (Spain), within the Biostatistics and Biomedical Data Science Unit.

The author acknowledges Virgilio Gómez-Rubio for his support and guidance during a research stay at the University of Castilla-La Mancha.

The author also thanks the Nuclear Medicine Department and Molecular Imaging Group of the University Clinical Hospital of Santiago de Compostela (CHUS) and the Health Research Institute of Santiago de Compostela (IDIS) for providing the clinical PET data used in this study.

# References
