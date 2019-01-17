# 2. CREAR TABLA DE OBSERVACIONES
# Combinar las tablas de variable objetivo y características en una sola: tabla de observaciones.
# 3 seg

# Parámetros
path_data = "C:/_JSmith/06 Cencosud Argentina/Hackaton/Datos/"
xdf_features = "caracteristicas.xdf"
csv_data = "Variable_Objetivo.csv"
xdf_observations = "observaciones.xdf"
csv_observations = "observaciones.csv"

# Iniciar cronómetro
t0 = Sys.time()

# Leer archivos de datos en data frames
df_data = rxDataStep(inData = paste(path_data, csv_data, sep = ""))
df_features = rxDataStep(inData = paste(path_data, xdf_features, sep = ""))

# Combinar ambos data frames
df_observations = merge(df_data, df_features)

# Conservar solamente las filas sin nulos
df_observations = df_observations[complete.cases(df_observations), ]

# Convertir columna Clase a factor, para poder usar después como variable dependiente en los modelos
df_observations$Clase = as.factor(df_observations$Clase)

# Guardar data frame de observaciones en archivo xdf para el modelo, y en csv para la visualización.
rxDataStep(inData = df_observations, outFile = paste(path_data, xdf_observations, sep = ""), overwrite = T)
cnn_observations = RxTextData(paste(path_data, csv_observations, sep = ""), delimiter = ";", decimalPoint = ",")
rxDataStep(inData = df_observations, outFile = cnn_observations, overwrite = T)

# Tiempo
print(Sys.time() - t0)
