# Guía de Contribución 🤝

Gracias por tu interés en contribuir a este proyecto. Este documento establece las directrices para contribuir de manera efectiva.

## Código de Conducta

Este proyecto espera que todos los contribuyentes sean respetuosos, constructivos y profesionales.

## 🚀 Cómo Contribuir

### 1. Fork y Clone
```bash
# Fork del repositorio en GitHub
# Luego clona tu fork
git clone https://github.com/vicenterojasmurua/ingresos-costo-vida-latinoamerica.git
cd ingresos-costo-vida-latinoamerica
```

### 2. Crear una Rama
```bash
# Crear rama descriptiva
git checkout -b feature/descripcion-cambio
# o para bugfixes
git checkout -b bugfix/descripcion-bug
```

### 3. Hacer Cambios
- Sigue las convenciones de código del proyecto
- Escribe comentarios claros en español
- Actualiza el README si es necesario

### 4. Commit y Push
```bash
git add .
git commit -m "Descripción clara del cambio"
git push origin feature/descripcion-cambio
```

### 5. Pull Request
- Abre un PR en GitHub
- Describe claramente qué cambios hiciste y por qué
- Asegúrate de que tu código funcione

## 📝 Convenciones de Código

### Scripts R
- Nombres de funciones: `snake_case`
- Nombres de variables: `snake_case`
- Comentarios descriptivos en español
- Máximo 100 caracteres por línea

Ejemplo:
```r
# Buen ejemplo
calcular_promedio_ingresos <- function(datos) {
  resultado <- datos %>%
    filter(!is.na(ingresos)) %>%
    summarise(promedio = mean(ingresos))
  return(resultado)
}
```

### Commits
Usa mensajes claros y descriptivos:
- ✨ `feat:` Nueva funcionalidad
- 🐛 `fix:` Corrección de bug
- 📚 `docs:` Cambios en documentación
- ♻️ `refactor:` Refactorización de código
- 🧪 `test:` Nuevas pruebas

Ejemplo:
```
feat: agregar análisis de correlación por región
fix: corregir carga de datos con fechas
docs: actualizar instrucciones de instalación
```

## 🧪 Testing

Si añades funcionalidad:
1. Prueba localmente en R/RStudio
2. Verifica que los scripts anteriores sigan funcionando
3. Documenta los resultados esperados

## 📋 Reportar Issues

Si encuentras un bug o tienes una sugerencia:
1. Abre un Issue en GitHub
2. Describe el problema claramente
3. Incluye pasos para reproducirlo (si es aplicable)
4. Menciona tu versión de R y paquetes (usa `sessionInfo()`)

## ✅ Checklist Antes de Hacer PR

- [ ] Mi código sigue las convenciones del proyecto
- [ ] He probado mi código localmente
- [ ] He actualizado la documentación si es necesario
- [ ] He añadido comentarios donde era necesario
- [ ] No hay conflictos con la rama main

¡Gracias por contribuir! 🙌
