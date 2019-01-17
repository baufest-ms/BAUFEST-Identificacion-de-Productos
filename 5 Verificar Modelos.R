# VERIFICAR MODELOS
# Algoritmos:
# 1. Arboles de decisión
# 2. Redes neuronales
# 48 seg

# Parámetros
path_data = "C:/_JSmith/06 Cencosud Argentina/Hackaton/Datos/"
path_models = "C:/_JSmith/06 Cencosud Argentina/Hackaton/Modelos/"
xdf_training = "entrenamiento.xdf"
xdf_testing = "verificacion.xdf"
csv_variables_umbrales = "variables_umbrales.csv"

# Iniciar cronómetro
t0 = Sys.time()

# Cargar variables a usar desde archivo de selección
df_variables_umbrales = read.csv2(paste0(path_models, csv_variables_umbrales), stringsAsFactors = F)
variables = df_variables_umbrales$Variable

# Fórmula
formulatxt = paste(variables, collapse = " + ")
formulatxt = paste("Clase ~",formulatxt)
formula = as.formula(formulatxt)

# Rutas de datos de entrenamiento y verificación
path_xdf_training = paste0(path_data, xdf_training)
nr = rxGetInfo(path_xdf_entrenamiento)$numRows
sqrtn = round(sqrt(nr), 0)
path_xdf_testing = paste0(path_data, xdf_testing)

# Cargar data frames
df_training = rxDataStep(path_xdf_training)
df_testing = rxDataStep(path_xdf_testing)

# 1) Arbol de Decisión - 6 sec
set.seed(0)
df_training = rxDataStep(inData = path_xdf_entrenamiento)
model_DTree = rxDTree(  formula = formula
                      , data = df_training
                      #, minSplit = sqrtn
                      #, maxNumBins = sqrtn
)

# 2) Red Neuronal - 4 sec
set.seed(0)
model_NeuralNet = rxNeuralNet(  formula = formula
                              , data = path_xdf_training
                              , type = "multiClass"
)

# Generar tablas de predicciones y calcular precisión:

# Tabla de precisiones
df_precision = data.frame(  Modelo = c("Arbol de Decisión", "Red Neuronal")
                          , Precision = rep(NA, 2)
                          )

# Arbol de Decisión
df_predictions = rxPredict(modelObject = model_DTree, data = df_testing, extraVarsToWrite = "Clase")
predCols = names(df_predictions)[grepl("_Pred", names(df_predictions))]
maxPred = apply(df_predictions[, predCols], MARGIN = 1, FUN = max)
nr = nrow(df_predictions)
predictions = rep(NA, nr)
for (i in 1:nr){
  max = maxPred[i]
  x = as.numeric(df_predictions[i, predCols])
  col = predCols[which(x==max)]
  predictions[i] = gsub(".", " ", gsub("_Pred", "", col), fixed = T)[1]
}
df_predictions$Clase_Pred = predictions
precision = nrow(df_predictions[df_predictions$Clase == df_predictions$Clase_Pred & !is.na(df_predictions$Clase_Pred), ])/nr
df_precision[df_precision$Modelo == "Arbol de Decisión", "Precision"] = precision

# Red Neuronal
df_predictions = rxPredict(modelObject = model_NeuralNet, data = df_testing, extraVarsToWrite = "Clase")
precision = nrow(df_predictions[df_predictions$Clase == df_predictions$PredictedLabel & !is.na(df_predictions$PredictedLabel), ])/nr
df_precision[df_precision$Modelo == "Red Neuronal", "Precision"] = precision

# Mostrar precisiones
print(df_precision)

# Mostrar tiempo
print(Sys.time()-t0)
