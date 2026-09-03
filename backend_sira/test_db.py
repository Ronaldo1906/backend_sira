import pymysql

try:
    connection = pymysql.connect(
        host='127.0.0.1',
        port=3306,
        user='root',
        password='',
        database='sira'
    )
    print("\n✅ ¡CONEXIÓN EXITOSA A MYSQL Y A LA BASE DE DATOS 'sira'!\n")
    connection.close()
except Exception as e:
    print("\n❌ ERROR DE CONEXIÓN:")
    print(e)
    print("\n")
