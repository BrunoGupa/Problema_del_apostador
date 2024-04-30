#Llenamos los siguientes datos para el problema:
premio <- 100
p <- 0.6


#Se determina el número de la población inicial
poblacion <- 5 * premio

#se define el número maximo de estados
maximo_st <- premio-1

#Definimos la funcion recompensa
Rew <- function(s){
  if(s == premio ){
    recompensa <- 1
  } else {
    recompensa <- 0
  } 
  return(recompensa)
}

#Fitness function
#Creamos la función fitness a través de simular 100(N-1) caminatas aleatorias sobre la política dada.
#El resultado de la función será el número de veces que se obtiene recompensa de 1 (alcanzar el premio max.)
#entre el total de iteraciones. 
#Aunque el resultado de la fitness_function es aleatorio, la Ley Débil de los Grandes Números
#asegura que el resultado es aproximadamente igual para todas las veces que se calcule. 

fitness_function <- function(cromosoma){
  #Se irá sumando la recompensa acumulada
  recompensa <- 0
  
  #Empezando en el 's' se apuesta lo que indica la política 'a' iniciando asi una C.A
  #Se toma como estado incial cada uno de los estados 's'
  for(s in 1:maximo_st){
    #Iniciando en 's' se repite 100 veces la C.A
    for(k in 1:100){
      ss <- s
      #Caminata aleatoria empesando en 's'. 
      #La C.A. termina cuando se alcanza el premio, se queda en 0, o la política es apostar 0.
      while(ss < premio){
        #se lanza la moneda al aire
        moneda <- rbinom(1,1,p)
        if (ss == 0) break
        if (cromosoma[ss] == 0) break
        #Si sale águila (==1), avanzamos al estado s+a
        #Si sale sol (==0), retrocedemos al estado s-a
        #('a' es la política del estado 's' )
        if(moneda == 1){
          ss <- ss + cromosoma[ss]
        } else {
          ss <- ss - cromosoma[ss]
        }
        recompensa <- recompensa + Rew(ss)
      }
    }
  }
  
  # Definimos 'fitness_value' como la recompensa obtenida entre las iteraciones realizadas
  # La ley de los grandes números nos asegura que para una misma política, el 'fitness_value'
  # será aproximadamente igual.
  fitness_value <- recompensa / (100 * maximo_st) #(num. de iteraciones * num. de estados)
  
  return(fitness_value)
  
}


 
#Se crea una población de individuos de tamaño 'poblacion' en el espacio de las posibles políticas
#Se califica a cada una y se guardan dentro del vector 'genpool_ga'.

#Generamos la población aleatoria
genpool_ga <- vector("list", poblacion)

i <- 1
for(i in 1:poblacion){
  #Creamos cada cromosoma dentro del espacio de políticas
  cromosoma <- vector("numeric", maximo_st)
  
  for(s in 1:maximo_st){
    #Para cada estado s, delimitamos lo maximo posible a apostar.
    apuesta_maxima <- min(s,premio-s)
    #Se escoge la acción 'a' aleatoriamente de entre las posibles 
    a <- sample(0:apuesta_maxima, 1, replace=TRUE)
    cromosoma[s] <- a
  }

  #Se califica cada cromosoma con la función fitness
  valor <- fitness_function(cromosoma)   
  #Se agrega al 'genpool_ga' cada nuevo cromosoma con su respectiva calificación de aptitud.
  genpool_ga[[i]] <- list(cromosoma, valor) 
  i <- i + 1
}



#Se crea 'random_padre' para escoger a dos padres.
#Para favorecer valores pequeños se generan dos números aleatorios entre 0 y 1 
# se multiplican entre sí. Después multiplicaremos este número
# por 'poblacion'. 
# 
#La parte entera de ese número tiene  mayor probabilidad de ser un entero pequeño.
# 
# Dicho número indica la posición del padre elegido dentro de una lista ordenada.

random_padre <- function(genpool_ga){
  #creamos el numero aleatorio.
  aleatorio =  runif(1) * runif(1) * (poblacion - 1)
  #tomamos al mayor entero menor o igual que 'aleatorio'.
  aleatorio = 1 + floor(aleatorio) 
  return(genpool_ga[[aleatorio]][[1]])
}




#Se define la función 'cruza', la cual combina la mitad de los genes de cada padre
#para formar un nuevo individuo.

cruza <- function(padre1, padre2){
  hijo <- vector("numeric", maximo_st)
  #'division' marca la mitad de los estados,
  division <- floor(maximo_st / 2)
  
  # en la primera mitad se copiarán los genes del padre1
  for(j in 1: division){
    hijo[j] <- padre1[j]
  }
  # en la segunda mitad los del padre2
  for(k in (division +1): maximo_st){
    hijo[k] <- padre2[k]
  }
  return(hijo)
}


#Definimos la mutación.
#Se escoge un gen (un estado 's') y dada la acción 'a' se muta con probabilidad 1/3
#a la acción 'a+1' y con 1/3 a la acción 'a-1'
mutacion <- function(cromosoma){
  # Elegimos de manera aleatoria la posición del gen.
  # se designa un entero aleatorio entre 1 y 'max_st'
  gen <- sample(1:maximo_st, 1) 
  
  #Para el gen (que es un estado), se delimita el espacio de posibles acciones.
  apuesta_maxima <- min(gen,premio - gen)
  
  #Se muta el gen con el número aleatorio
  alelo <- cromosoma[gen] + sample(c(-1,0,1),1, replace = TRUE) 
  #Si 'alelo' pertenece al conjunto [0,apuesta_maxima], se queda como está.
  #Si 'alelo < 0' lo cambiamos a 'apuesta_maxima'
  # y si 'alelo > apuesta_maxima' lo cambiamos a 0.
  
  # Estas operaciones son con el fin de que las mutaciones generen un elemento
  # dentro del espacio de posibles soluciones.
  posibles_apuestas <- c(1:apuesta_maxima)
  if( (alelo %in% posibles_apuestas) == TRUE){
    alelo <- alelo
  } else {
    if(alelo < 0 ){
      alelo <- apuesta_maxima
    } else {
      alelo <- 0
    }
  }
  
  #se sustituye al 'alelo'  en su posición correspondiente.
  cromosoma[gen] <- alelo
  
  return(cromosoma)
}


# Lo que haremos ahora es un ciclo while donde
# 1. Ordenamos la 'genpool_ga' de acuerdo a su valor fitness.
# 2. Si el mejor elemento (primer individuo de la lista) tiene fitness > 0.8
# se termina el ciclo, en caso contrario continua.
# 3. Selección de los padres
# 4. Cruza
# 5. Mutación
# 6. Se evalúa al nuevo individuo
# 7. Se inserta a la 'genpool_ga' sólo si es mejor que alguien de la población. 
# Se desecha al individuo peor valuado.


cont_repeticiones <- 0
l <- 1
while(TRUE){
  mejor_aptitud_anterior <- genpool_ga[[1]][[2]]
  #1. Ordenamos la población de mayor a menor, con respecto a su fitness.
  genpool_ga <- genpool_ga[order(sapply(genpool_ga,'[[',2), decreasing = TRUE)]
  
  #imprimimos al mejor individuo de la lista
  print(paste0("Iteracion ", l, "   Fitness: ", genpool_ga[[1]][[2]]))
  #y guardamos su nivel de aptitud
   
  l <- l +1
  
  # 2. Si el mejor elemento (primer individuo de la lista) tiene fitness == 1
  # o si transcurren mil generaciones sin mejora
  # se termina el ciclo, en caso contrario continua.
  if(genpool_ga[[1]][[2]] == 1){
    break
  }
  
  if(genpool_ga[[1]][[2]] == mejor_aptitud_anterior ){
    cont_repeticiones <- cont_repeticiones + 1
    if(cont_repeticiones == 1000){
      break
    }}else{
      cont_repeticiones <- 0
    }
  
  
  
  #3. Selección de los padres
  padre1 <- random_padre(genpool_ga)
  padre2 <- random_padre(genpool_ga)
  
  # 4. Cruza
  hijo <- cruza(padre1, padre2)

  # 5. Mutación
  hijo <- mutacion(hijo)
  
  # 6. Valuación del nuevo individuo 
  #(Se crea una lista en donde se etiqueta al hijo con su valor fitness)
  hijo_evaluado <- list(hijo, fitness_function(hijo))
  hijo_evaluado
  # 7. Se inserta al hijo en la 'genpool_ga' sólo si es mejor que alguien de la población. 
  # Se desecha al individuo peor valuado.
  if(hijo_evaluado[[2]] > genpool_ga[[poblacion]][[2]]){
    genpool_ga[[poblacion]] <- hijo_evaluado
  }
  
}
genpool_ga[[1]][[1]]
fitness_function(genpool_ga[[1]][[1]])

#***************************
#Gráfica de las políticas óptimas

#plot(genpool_ga[[1]][[1]], xlab = "Estado", ylab = "Politica mejor valuada")

plot(genpool_ga[[1]][[1]],type = "l", xlab = "Estado", ylab = "Politica mejor valuada", main = paste("Aptitud ", genpool_ga[[1]][[2]]))

# Add legend to plot 
legend("topleft", 
       inset=.02, 
       cex = .75,  
       c(paste("Premio = ", premio), paste("p = ",p)), 
       #lty=c(1,1), 
       #lwd=c(2,2), 
       bg="grey96")
