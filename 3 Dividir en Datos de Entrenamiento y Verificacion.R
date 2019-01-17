# 3. DIVIDIR OBSERVACIONES EN CONJUNTOS PARA ENTRENAMIENTO Y VERIFICACION
# 5 seg

# Paquetes
# install.packages("caret")
library(caret)

# Parámetros
path_data = "C:/_JSmith/06 Cencosud Argentina/Hackaton/Datos/"
xdf_observations = "observaciones.xdf"
xdf_training = "entrenamiento.xdf"
xdf_testing = "verificacion.xdf"
csv_training = "entrenamiento.csv"
csv_testing = "verificacion.csv"
pe = 0.5 # Proporcion de observaciones para entrenamiento. (Para verificación: 1-pe)

# Iniciar cronómetro
t0 = Sys.time()

# Importar tabla de observaciones en data frame
df_observations = rxDataStep(inData = paste0(path_data, xdf_observations))
df_observations$Clase = as.character(df_observations$Clase)

# Incluir en la tabla de observaciones solamente las imágenes existentes en la carpeta de imágenes.
image_names = list.files(path_images, pattern = "*.jpg")
image_names = c(image_names, list.files(path_images, pattern = "*.png"))
df_image_names = data.frame(Pathfile = image_names, stringsAsFactors = F)
df_observations = df_observations[df_observations[, "ArchivoImagen"] %in% image_names, ]

# Crear vector de selección de filas para conjunto de entrenamiento
set.seed(0)
inTrain = createDataPartition(df_observations$Clase, p = pe, list = F)

# Crear data frames de entrenamiento y verificación
df_training = df_observations[inTrain,]
df_testing = df_observations[-inTrain,]

# Verificar distribución de la variable dependiente
table(df_observations$Clase) # 30%
table(df_training$Clase) # 30%
table(df_testing$Clase) # 30%

# Volver a convertir columna Clase a factor, para poder usar después como variable dependiente en los modelos
df_training$Clase = as.factor(df_training$Clase)
df_testing$Clase = as.factor(df_testing$Clase)

# Guardar data frames de entrenamiento y verificación, en archivos xdf para el modelo, y en csv para la visualización.
rxDataStep(inData = df_training, outFile = paste0(path_data, xdf_training), overwrite = T)
rxDataStep(inData = df_testing, outFile = paste0(path_data, xdf_testing), overwrite = T)
write.csv2(df_training, file = paste0(path_data, csv_training), row.names = F)
write.csv2(df_testing, file = paste0(path_data, csv_testing), row.names = F)

# Consultar cantidad de filas guardadas en entrenamiento y verificación
print(rxGetInfo(paste0(path_data, xdf_training))$numRows) # 30
print(rxGetInfo(paste0(path_data, xdf_testing))$numRows)

# Tiempo
print(Sys.time() - t0) # 5 seg
