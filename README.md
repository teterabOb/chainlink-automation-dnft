# Chainlink Automation - Dynamic NFT

Tarea - TBA

La eliminación de la estructura "enum" se realiza con el objetivo de manejar una cantidad elevada de
estados en los NFT de manera más eficiente y conveniente. En lugar de utilizar una estructura "enum"
para representar cada estado de un NFT, se ha optado por representarlos directamente mediante un
número entero "uint". Esto permite una representación más compacta y eficiente de los estados del NFT,
lo que puede ser especialmente útil cuando se manejan grandes cantidades de estados posibles. Además,
al utilizar un número entero en lugar de una estructura "enum", se pueden realizar operaciones
aritméticas y de comparación directamente con los estados del NFT, lo que simplifica el proceso de
programación y mejorar el rendimiento de la aplicación en general, y particularmente observado en
las funciones de actualización. En resumen, la eliminación de la estructura "enum" en favor de un
número entero "uint" es una mejora importante en términos de eficiencia y conveniencia para el
manejo de grandes cantidades de estados posibles de un NFT, aunque desde el punto de vista
didactico puede ser en principio algo menos intuitivo.
