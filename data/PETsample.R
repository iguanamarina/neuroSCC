library(oro.nifti)

# Intentar cargar la imagen con system.file
filename <- system.file("./inst/extdata", "003_S_1059.img", package = "neuroSCC")

# Verificar si el archivo fue encontrado
if (filename == "") {
  # Si no se encuentra, usar una ruta relativa durante el desarrollo
  filename <- "./inst/extdata/003_S_1059.img"
}

# Cargar la imagen, asegurándose de que el archivo existe
if (file.exists(filename)) {
  PETsample <- oro.nifti::readNIfTI(filename)
  # Guardar el objeto en el directorio 'data/' de tu paquete
  usethis::use_data(PETsample, overwrite = TRUE)
} else {
  stop("File not found: ", filename)
}
