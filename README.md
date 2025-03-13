
# neuroSCC: Bridging Simultaneous Confidence Corridors with PET Neuroimaging

<a href="https://github.com/iguanamarina/neuroSCC">
<img src="man/figures/logo.png" align="right" width="150" /> </a>

🚀 **`neuroSCC`** facilitates **structured processing of PET
neuroimaging data** for the estimation of **Simultaneous Confidence
Corridors (SCCs)**.

It integrates neuroimaging and statistical methodologies to: - 📥 **Load
and preprocess** PET neuroimaging files. - 🔬 **Transform data** for
**Functional Data Analysis (FDA)**. - 🎯 **Extract meaningful contours**
and identify significant SCC regions. - 📊 **Compare SCC-based
analyses** with gold-standard methods like **SPM**.

The package bridges **neuroimaging tools** (`oro.nifti`) with advanced
**statistical methods** (`ImageSCC`), supporting **one-group, two-group,
and single-patient vs. group comparisons**.

📌 Developed as part of the **Ph.D. thesis**:  
*“Development of statistical methods for neuroimage data analysis
towards early diagnosis of neurodegenerative diseases”*,  
**University of Santiago de Compostela**.

------------------------------------------------------------------------

## 🚀 Badges

<p>
<img src="https://img.shields.io/badge/Admin-IGUANAMARINA-informational?style=for-the-badge&logo=github" alt="Admin">
<img src="http://www.repostatus.org/badges/latest/active.svg" alt="Project Status: Active" />
<img src="https://img.shields.io/badge/lifecycle-Stable-4cc71e.svg" alt="Lifecycle: Stable" />
<img src="https://img.shields.io/badge/Contributors-1-brightgreen" alt="Contributors" />
<img src="https://img.shields.io/badge/Commits-30-brightgreen" alt="Commits" />
<img src="https://img.shields.io/badge/Issues-9-brightgreen" alt="Issues" />
<img src="https://img.shields.io/badge/Size-9959KB-brightgreen" alt="Size" />
<img src="https://img.shields.io/badge/R-276DC3.svg?style=for-the-badge&logo=r&logoColor=white" alt="R" />
</p>

------------------------------------------------------------------------

------------------------------------------------------------------------

# 📖 Table of Contents —-

<details open="open">
<summary>
📖 Click to expand
</summary>
<ol>
<li>
<a href="#about-the-project"> ➤ About The Project</a>
</li>
<li>
<a href="#installation"> ➤ Installation</a>
</li>
<li>
<a href="#basic-usage"> ➤ Basic Usage</a>
</li>
<li>
<a href="#functions-overview"> ➤ Functions Overview</a>
</li>
<li>
<a href="#vignette"> ➤ Vignette & Full Workflow</a>
</li>
<li>
<a href="#references"> ➤ References</a>
</li>
</ol>
</details>

------------------------------------------------------------------------

# 1️⃣ About the Project —-

## Why Use `neuroSCC`? —-

PET neuroimaging data is **complex**, requiring careful **processing and
statistical validation**. `neuroSCC` is designed to:

✔ **Automate Preprocessing**: Load, clean, and structure PET data 📂  
✔ **Standardize Analysis**: Convert images into FDA-compatible formats
🔬  
✔ **Provide SCC Estimations**: Identify **significant regions** with
confidence 🎯  
✔ **Enable Method Comparisons**: SCC vs. **SPM performance evaluation**
📊

It is **particularly suited for**: - **Clinical neuroimaging research**
(Alzheimer’s disease, neurodegeneration). - **Statistical validation of
imaging methods**. - **Comparisons between SCC and other statistical
approaches**.

------------------------------------------------------------------------

# 2️⃣ Installation —-

## 📦 From GitHub —-

    #> Rcpp       (1.0.13      -> 1.0.14     ) [CRAN]
    #> geometry   (0.5.0       -> 0.5.2      ) [CRAN]
    #> jsonlite   (1.8.9       -> 1.9.1      ) [CRAN]
    #> data.table (1.16.2      -> 1.17.0     ) [CRAN]
    #> RNifti     (1.7.0       -> 1.8.0      ) [CRAN]
    #> memisc     (0.99.31.8.1 -> 0.99.31.8.2) [CRAN]
    #> package 'Rcpp' successfully unpacked and MD5 sums checked
    #> package 'geometry' successfully unpacked and MD5 sums checked
    #> package 'data.table' successfully unpacked and MD5 sums checked
    #> package 'RNifti' successfully unpacked and MD5 sums checked
    #> package 'memisc' successfully unpacked and MD5 sums checked
    #> 
    #> The downloaded binary packages are in
    #>  C:\Users\juana\AppData\Local\Temp\RtmpI3kLAy\downloaded_packages
    #> ── R CMD build ─────────────────────────────────────────────────────────────────
    #>       ✔  checking for file 'C:\Users\juana\AppData\Local\Temp\RtmpI3kLAy\remotes2cd43e644aa4\iguanamarina-neuroSCC-6838d08/DESCRIPTION'
    #>       ─  preparing 'neuroSCC':
    #>    checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   ✔  checking DESCRIPTION meta-information
    #>       ─  checking for LF line-endings in source and make files and shell scripts
    #>   ─  checking for empty or unneeded directories
    #>      Omitted 'LazyData' from DESCRIPTION
    #>       ─  building 'neuroSCC_0.11-0.tar.gz'
    #>      
    #> 

## 🔜 From CRAN (Future) —-

------------------------------------------------------------------------

# 3️⃣ Basic Usage —-

### **Minimal Working Example** —-

``` r
# Load package
library(neuroSCC)

# Load a PET neuroimaging file
pet_data <- neuroCleaner("path/to/file.nii")

# Process for functional data analysis
processed_data <- matrixCreator(pet_data)

# Compute SCCs
SCC_result <- ImageSCC::scc.image(processed_data)

# Visualize results
plot(SCC_result)
```

------------------------------------------------------------------------

# 4️⃣ Functions Overview —-

This package contains **several core functions** for neuroimaging data
processing:

<details>
<summary>
🧼 neuroCleaner(): Load & Clean PET Data
</summary>

``` r
# Load a NIFTI file and structure the data
clean_data <- neuroCleaner("path/to/file.nii")
head(clean_data)
```

</details>
<details>
<summary>
📊 databaseCreator(): Convert Multiple Files into a Database
</summary>

``` r
# Process multiple PET images into a database
database <- databaseCreator(pattern = ".*nii")
```

</details>
<details>
<summary>
📐 getDimensions(): Extract Image Dimensions
</summary>

``` r
# Extract spatial dimensions of a PET scan
dims <- getDimensions("path/to/file.nii")
```

</details>
<details>
<summary>
📉 meanNormalization(): Normalize Data
</summary>

``` r
# Apply mean normalization for functional data analysis
normalized_matrix <- meanNormalization(matrixData)
```

</details>
<details>
<summary>
📈 neuroContour(): Extract Contours
</summary>

``` r
# Extract region contours from neuroimaging data
contours <- neuroContour("path/to/file.nii")
```

</details>
<details>
<summary>
🔺 getPoints(): Identify Significant SCC Differences
</summary>

``` r
# Extract significant points from SCC results
points <- getPoints(SCC_result)
```

</details>

------------------------------------------------------------------------

# 5️⃣ Vignette & Full Workflow —-

A full walkthrough of using `neuroSCC` from start to finish is available
in the vignette.

[📄 **Click here to view the full
vignette**](https://github.com/iguanamarina/neuroSCC/vignettes/workflow.html)

------------------------------------------------------------------------

# 6️⃣ References —-

- Wang, Y., Wang, G., Wang, L., Ogden, R.T. (2020). *Simultaneous
  Confidence Corridors for Mean Functions in Functional Data Analysis of
  Imaging Data*. Biometrics, 76(2), 427-437.  
- [Ph.D. Thesis: Development of statistical methods for neuroimage data
  analysis towards early diagnosis of neurodegenerative
  diseases](https://github.com/iguanamarina/PhD-thesis)

### ✅ **Next Steps**

- **Review and Edit**: Fill in placeholders `[Explain this]` and adjust
  descriptions.  
- **Style Tweaks**: Adjust layout, spacing, or visuals as needed.  
- **Focus on Specific Sections**: Start refining details section by
  section.

Let me know how you’d like to proceed! 🚀 \`\`\`

This version: ✔ **Uses the latest DESCRIPTION file information**.  
✔ **Pulls function descriptions from documentation**.  
✔ **Improves layout & formatting** for readability.  
✔ **Ensures structured sections for RStudio Outline**.

Would you like to **iterate on any specific section next**? 🚀

------------------------------------------------------------------------

# 🔧 Developer Cheatsheet (For Personal Use) —-

------------------------------------------------------------------------
