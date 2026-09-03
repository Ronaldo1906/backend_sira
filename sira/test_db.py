import pymysql

try:
    connection = pymysql.connect(
        host='127.0.0.1',
        port=3306,
        user='root',
<<<<<<< HEAD
        password='', # Si en MySQL Workbench usas contraseña, ponla dentro de las comillas ''
=======
        password='',
>>>>>>> ad92ea0e2db15c6919efa72cd1986656fccb9d9f
        database='sira'
    )
    print("\n✅ ¡CONEXIÓN EXITOSA A MYSQL Y A LA BASE DE DATOS 'sira'!\n")
    connection.close()
except Exception as e:
    print("\n❌ ERROR DE CONEXIÓN:")
    print(e)
    print("\n")
