
# neuroSCC: Bridging Simultaneous Confidence Corridors with PET Neuroimaging —-

<img src="man/figures/logo.png" width="200px" style="display: block; margin: auto 0 auto auto;" />

🚀 **`neuroSCC`** facilitates **structured processing of PET
neuroimaging data** for the estimation of **Simultaneous Confidence
Corridors (SCCs)**. It integrates neuroimaging and statistical
methodologies to: - 📥 Load and preprocess PET neuroimaging files. - 🔬
Transform data for **Functional Data Analysis (FDA)**. - 🎯 Extract
meaningful **contours and significant SCC regions**. - 📊 Compare
SCC-based analyses to **gold-standard methods like SPM**.

The package bridges established **neuroimaging** tools (`oro.nifti`)
with advanced **statistical** methods (`ImageSCC`), supporting
**one-group, two-group, and single-patient vs. group comparisons**.

📌 Developed as part of the **Ph.D. thesis**:  
*“Development of statistical methods for neuroimage data analysis
towards early diagnosis of neurodegenerative diseases”*,  
**University of Santiago de Compostela**.

------------------------------------------------------------------------

## 🚀 Badges —-

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
