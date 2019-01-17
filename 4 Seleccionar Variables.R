# 4. SELECCIONAR VARIABLES
# Para cada clase, se seleccionan las variables que claramente permiten saber si un objeto es de la clase o no.
# La definición precisa es: Una variable x permite saber si el objeto i pertenece a la clase c, si se cumple la condición:
# max(min0, min1) > min(max0, max1)
# donde min0 = mínimo valor de x de las observaciones en que i no pertenece a c
# donde min1 = mínimo valor de x de las observaciones en que i sí pertenece a c
# donde max0 = máximo valor de x de las observaciones en que i no pertenece a c
# donde max1 = máximo valor de x de las observaciones en que i sí pertenece a c
# Al final se genera una tabla de las variables seleccionadas, con sus respectivos umbrales.
# 6 seg

# Parámetros
path_data = "C:/_JSmith/06 Cencosud Argentina/Hackaton/Datos/"
path_models = "C:/_JSmith/06 Cencosud Argentina/Hackaton/Modelos/"
xdf_training = "entrenamiento.xdf"
csv_variables_umbrales = "variables_umbrales.csv"

# Iniciar cronómetro
t0 = Sys.time()

# Importar tabla de entrenamiento en data frame
df_training = rxDataStep(inData = paste0(path_data, xdf_training))
nc = ncol(df_training)

# Obtener clases y variables
clases = unique(df_training$Clase)
variables = names(df_training)
variables = variables[substr(variables, 0, 1) == "x"]
nclas = length(clases)
nvars = length(variables)

# Crear tabla de variables y umbrales
df_variables_umbrales = expand.grid(variables, clases, stringsAsFactors = F)
names(df_variables_umbrales)[2] = "Clase"
names(df_variables_umbrales)[1] = "Variable"
df_variables_umbrales$min0 =  NA
df_variables_umbrales$max0 =  NA
df_variables_umbrales$min1 =  NA
df_variables_umbrales$max1 =  NA
df_variables_umbrales$MINmax =  NA
df_variables_umbrales$MAXmin =  NA
df_variables_umbrales$Umbral =  NA

# Calcular las columnas de tabla de variables y umbrales
for (c in 1:nclas){ # Para cada clase
  clase = clases[c]
  df_variables_umbrales[df_variables_umbrales$Clase == clase, "min0"] = apply(df_training[df_training$Clase != clase, 3:nc], MARGIN = 2, FUN = min)
  df_variables_umbrales[df_variables_umbrales$Clase == clase, "max0"] = apply(df_training[df_training$Clase != clase, 3:nc], MARGIN = 2, FUN = max)
  df_variables_umbrales[df_variables_umbrales$Clase == clase, "min1"] = apply(df_training[df_training$Clase == clase, 3:nc], MARGIN = 2, FUN = min)
  df_variables_umbrales[df_variables_umbrales$Clase == clase, "max1"] = apply(df_training[df_training$Clase == clase, 3:nc], MARGIN = 2, FUN = max)
  df_variables_umbrales[df_variables_umbrales$Clase == clase, "MINmax"] = apply(df_variables_umbrales[df_variables_umbrales$Clase == clase, c("max0", "max1")], MARGIN = 1, FUN = min)
  df_variables_umbrales[df_variables_umbrales$Clase == clase, "MAXmin"] = apply(df_variables_umbrales[df_variables_umbrales$Clase == clase, c("min0", "min1")], MARGIN = 1, FUN = max)
}

# Conservar solamente las filas donde MAXmin > MINmax
df_variables_umbrales = subset(df_variables_umbrales, subset = MAXmin > MINmax)

# Calcular umbral para cada variable
df_variables_umbrales$Umbral = apply(df_variables_umbrales[, c("MINmax", "MAXmin")], MARGIN = 1, FUN = mean)

# Guardar tabla
write.csv2(df_variables_umbrales, file = paste0(path_models, csv_variables_umbrales), row.names = F)

# Mostrar tiempo
print(Sys.time()-t0)