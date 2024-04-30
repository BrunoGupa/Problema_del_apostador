#Llenamos los siguientes datos para el problema:
premio <- 100
p <- 0.5
N <- 100 #número de iteraciones de funciones de valor optimo que calcularemos, donde N=0,1,2,...


#se define el número maximo de estados
maximo_st <- premio-1

#Definimos la funcion recompensa
R <- function(s,a){
  if(s+a == premio ){
    recompensa <- 1
  } else {
    recompensa <- 0
  } 
  return(recompensa)
}

#Definimos la trancision entre estados dada una accion "a". 
transicion <- function(s_prima,s,a){
  if(s_prima == s+a){
    proba <- p
  } else {
    if(s_prima == s-a){
      proba <- 1-p
    } else {
      proba <- 0
    }
  }
  return(proba)
}

# Creamos la fución de utilidad ponderada por las transiciones
# de cada estado i.e. \sum_{s'} T(s'\vert s,a) U_{n-1})(s').
Utilidad_ponderada <- function(s,a){
  z<-0
  for(w in 1:maximo_st){
    z <- z + transicion(w,s,a) * U[w]
  } 
  return(z)
}


#Calculamos U_0 
U <- vector()
for(s in 1:maximo_st){
  U[s] <- 0
}

#convertimos a U en U2 pues es necesario para que funcione el 
#siguiente ciclo for.
U2 <- U


#Se crea una lista en donde se guardarán los resultados de la función de valor.
value_function <- vector("numeric", maximo_st)
#y otra donde se guardarán todas las funciones de valor de cada iteracion.
all_value_function <- vector("list", N)


#Se crea un vector donde se guardarán las políticas óptimas de cada estado
politicas_optimas <- vector("list", maximo_st)

# Hacemos un ciclo for para calcular hasta la N-ésima función U
for(n in 1:N){
  #tomamos al vector U_{n-1} de la iteración anterior
  U <- U2
  #Creamos un vector vacio que será U_n
  U2 <- vector()
  
  # Para cada s en S={1,..,maximo_st}, se calcula U_n(s) 
  # utilizando un ciclo for.
  for(s in 1:maximo_st){
    #Con s fijo, delimitamos lo maximo posible a apostar.
    apuesta_maxima <- min(s,premio-s)
    
    #creamos un vector vacío en donde se pondrán las valuaciones
    #de las posibles utilidades.
    utilidades <- vector()
    for(a in 0:apuesta_maxima){
      utilidades[a+1] <- R(s,a) + Utilidad_ponderada(s,a)
    }
    
    #para un estado s dado, se encuentra el máximo de las utilidades
    #y de este modo se determina a U_n(s).
    U2[s] <- max(utilidades)
    
    #Se guarda este valor en la lista
    value_function[s] <- U2[s]
    
    # Ahora encontraremos la accion a con la que se alcanza la maxima utiliad
    pi <- which(utilidades == max(utilidades))
    pi <- pi-1
    #Se guarda este valor en la lista de políticas optimas
    politicas_optimas[[s]] <- pi
    
  }
  
  all_value_function[[n]] <- value_function
}


#***************************
#Gráfica de las políticas óptimas

y_1 <- vector("numeric", maximo_st)
for(i in 1:maximo_st){
  y_1[i] <- politicas_optimas[[i]][1]
}
plot(y_1, xlab = "Estado", ylab = "Politicas optimas")

y <- vector("numeric", maximo_st)
for(j in 2:5){
  for(i in 1:maximo_st){
    y[i] <- politicas_optimas[[i]][j]
  }
  points(y)
}


#***************************
#Gráfica de la función de valor.
plot(all_value_function[[N]], type = "l", col = "blue", xaxt = "n", yaxt="n",  xlab = "Estado", ylab = "Valor estimado")
lines(all_value_function[[2]], type = "l", col = "red")
lines(all_value_function[[3]], type = "l", col = "green")
lines(all_value_function[[1]], type = "l", col = "magenta")
lines(all_value_function[[4]], type = "l", col = "cyan")

# Define the position of tick marks
v1 <- c(1,25,50,75,99)

# Define the labels of tick marks
v2 <- c("1","25","50","75","99")

# Add an axis to the plot 
axis(side = 1, 
     at = v1, 
     labels = v2,
     tck=-.05)

axis(side = 2, 
     at = c(0,0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.4,2.6), 
     labels = c("0","0.2","0.4","0.6","0.8","1.0","1.2","1.4","1.6","1.8","2.0","2.2","2.4","2.4","2.6"),
     tck=-.05)

# Add legend to plot 
legend("topleft", 
       inset=.05, 
       cex = .75,  
       c("paso 1","paso 2","paso 3", "paso 4", "paso 32"),
       lty=c(1,1), 
       lwd=c(2,2), 
       col=c("magenta", "red", "green", "cyan", "blue"), 
       bg="grey96")
