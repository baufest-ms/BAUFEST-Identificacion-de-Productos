# 1. EXTRAER CARACTERISTICAS
# Extraer las características de todas las imágenes, y guardar data frame en archivo xdf.
# 19 seg

# Parámetros
path_images = "C:/_JSmith/06 Cencosud Argentina/Hackaton/Datos/Imagenes/"
path_data = "C:/_JSmith/06 Cencosud Argentina/Hackaton/Datos/"
xdf_caracteristicas = "caracteristicas.xdf"
csv_caracteristicas = "caracteristicas.csv"

# Iniciar cronómetro
t0 = Sys.time()

# Leer los nombres de los archivos de imágenes en un vector, y convertir a data frame.
image_names = list.files(path_images, pattern = "*.jpg", full.names = T)
image_names = c(image_names, list.files(path_images, pattern = "*.png", full.names = T))
df_image_names = data.frame(Pathfile = image_names, stringsAsFactors = F)
n = length(image_names) # Cantidad de imágenes

# Obtenener el vector de características para cada imagen, y guardar en data frame. # 15 seg
# Cada fila es una imagen; cada característica es una variable (columna), se obtienen 4096.
df_image_caracteristicas = rxFeaturize(
                                  data = df_image_names
                                , mlTransforms = list(
                                                        loadImage(vars = list(x = "Pathfile"))
                                                      , resizeImage(vars = "x", width = 227, height = 227)
                                                      , extractPixels(vars = "x")
                                                      , featurizeImage(var = "x", dnnModel = "alexnet")
                                                      )
)

# Cambiar nombre de columna "Pathname" column a "ArchivoImagen", y quitar ruta.
# Esto será la llave primaria en las tablas de características y la variable objetivo.
names(df_image_caracteristicas)[which(names(df_image_caracteristicas) == "Pathfile")] = "ArchivoImagen"
df_image_caracteristicas$ArchivoImagen = gsub(path_images, "", df_image_caracteristicas$ArchivoImagen)

# Normalizar cada variable de características, esto es. aplicarle una función al intervalo [0, 1].
normalise = function(x){
# Maps vector x to interval [0, 1].
  minimum = min(x)
  maximum = max(x)
  if (maximum > minimum) {
    return((x - minimum) / (maximum - minimum))
  } else {
    return(x - minimum)
  }
}
nc = ncol(df_image_caracteristicas)
df_image_caracteristicas = cbind(data.frame(ArchivoImagen = df_image_caracteristicas[, 1]), as.data.frame(apply(df_image_caracteristicas[2:nc], 2, normalise)))

# Guardar data frame de características en archivo xdf file para el modelo, y archivo csv para visualizar fácilmente.
rxDataStep(inData = df_image_caracteristicas, outFile = paste(path_data, xdf_caracteristicas, sep = ""), overwrite = T)
cnn_caracteristicas = RxTextData(paste(path_data, csv_caracteristicas, sep = ""), delimiter = ";", decimalPoint = ",")
rxDataStep(inData = df_image_caracteristicas, outFile = cnn_caracteristicas, overwrite = T)

print(paste(as.character(n), "imágenes procesadas")) # 33
print(Sys.time() - t0)
