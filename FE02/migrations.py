import os
import oracledb as oracle
from dotenv import load_dotenv
import pymongo

class migrations:
    def __init__(self):
        self.run_requirements()
        self.OracleConnection = self.connect(option="Oracle")
        self.MongoConnection = self.connect(option="MongoDB")  
        if self.OracleConnection!=None and self.MongoConnection!=None:
            self.migrations()
            self.OracleConnection.close()
            self.MongoConnection.close()
            print("Migrations completed successfully")

    def migrations(self):
        documents = self.getDataFromOracle()
        #Verify if BDNOSQL database already exists
        if "BDNOSQL" in self.MongoConnection.list_database_names():
            print("Database BDNOSQL already exists")
            #Drop the database
            self.MongoConnection.drop_database("BDNOSQL")
            print("Dropped the database BDNOSQL")
        #Create mongoDB database
        db = self.MongoConnection["BDNOSQL"]
        #Create collections
        collection = db["Titulos"]
        #Insert data into the collections
        collection.insert_many(documents.values())
        print("Sucessfully inserted all data into the MongoDB")

        
    def getDataFromOracle(self):

        cursor = self.OracleConnection.cursor()
        query = """
            select titulo.id_titulo as id_titulo, 
            titulo.titulo as titulo, 
            titulo.preco as preco, 
            titulo.data_compra, 
            titulo.id_editora as id_editora, 
            editora.nome as nome_editora, 
            titulo.id_suporte as id_suporte,
            suporte.nome as nome_suporte, 
            genero.nome as nome_genero, 
            autor.id_autor as id_autor,
            autor.nome as nome_autor
            from titulo
            inner join editora on titulo.id_editora = editora.id_editora
            inner join suporte on titulo.id_suporte = suporte.id_suporte
            inner join genero on titulo.id_genero = genero.id_genero
            inner join autor on titulo.id_autor = autor.id_autor
        """

        cursor.execute(query)
        result = cursor.fetchall()
        cursor.close()
        documents = {}
        for line in result:
            document = {
                "_id" : 0,
                "id_titulo": 0,
                "titulo":"",
                "preco":0.0,
                "data_compra": "",
                "editora": {
                    "id_editora": 0,
                    "nome": ""
                },
                "suporte":{
                    "id_suporte": 0,
                    "nome": ""
                },
                "genero":{
                    "id_genero": 0,
                    "nome": ""
                },
                "autor":{
                    "id_autor": 0,
                    "nome": ""
                },
                "musicas" : [
                ],
                "reviews" : [
                ]
            }
            document["_id"] = line[0]
            document['id_titulo'] = line[0]
            document['titulo'] = line[1]
            document['preco'] = line[2]
            document['data_compra'] = line[3]
            document['editora']['id_editora'] = line[4]
            document['editora']['nome'] = line[5]
            document['suporte']['id_suporte'] = line[6]
            document['suporte']['nome'] = line[7]
            document['genero']['nome'] = line[8]
            document['autor']['id_autor'] = line[9]
            document['autor']['nome'] = line[10]
            documents[line[0]] = document

        #Populate musicas and reviews

        queryMusicasAndReviews = f"""
            select musica.id_titulo as id_titulo,
            musica.id_musica as id_musica,
            musica.nome as nome_musica,
            autor.id_autor as id_autor,
            autor.nome as nome_autor,
            review.id_review as id_review,
            review.dta_review as data_review,
            review.conteudo as conteudo
            from musica
            inner join autor on musica.id_autor = autor.id_autor
            inner join titulo on musica.id_titulo = titulo.id_titulo
            inner join review on titulo.id_titulo = review.id_titulo

        """
        cursor = self.OracleConnection.cursor()
        cursor.execute(queryMusicasAndReviews)
        result = cursor.fetchall()
        cursor.close()
        

        for line in result:
            titulo = line[0]
            documents[titulo]["musicas"].append({
                "id_musica": line[1],
                "nome": line[2],
                "autor": {
                    "id_autor": line[3],
                    "nome": line[4]
                }
            })
            documents[titulo]["reviews"].append({
                "id_review": line[5],
                "data_review": line[6],
                "conteudo": line[7]
            })


        print("Sucessfully got all data from the Oracle DB")
        return documents


    def connect(self, option):
        if (option == "Oracle" or option==0):
            try: 
                load_dotenv()
                wpassword = os.getenv('ORACLE_WALLET_PASSWORD')
                password = os.getenv('ORACLE_DB_PASSWORD')

                connection = oracle.connect(
                    config_dir="/Users/rkeat/Desktop/Universidade/1anoMestrado/2semestre/BDNOSQL/FE02/Wallet from Oracle Cloud",
                    user="admin",
                    password=password,
                    dsn="h9cwd9h9aj0lzcoc_tp",
                    wallet_location="/Users/rkeat/Desktop/Universidade/1anoMestrado/2semestre/BDNOSQL/FE02/Wallet from Oracle Cloud",
                    wallet_password=wpassword
                )

                print("Successfull connection")
                return connection
            except:
                print('Error connecting to the database')
                return None
            
        if (option == "MongoDB" or option==1):
            try:
                client = pymongo.MongoClient("mongodb://localhost:27017/")
                print("Successfull connection")
                return client
            except:
                print('Error connecting to the database')
                return None

    def run_requirements(self):
        os.system('pip install -r requirements.txt')

migrations()