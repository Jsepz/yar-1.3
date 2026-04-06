
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host              : '',
  user              : 'root',
  password          : 'admin',          // XAMPP padrão não tem senha
  database          : 'yara_db',
  port              : 3306,
  waitForConnections: true,
  connectionLimit   : 10,
  queueLimit        : 0
});

// Testa a conexão uma vez quando o servidor inicia
// e avisa no terminal se algo estiver errado
pool.getConnection()
  .then(conn => {
    console.log('✅ MySQL conectado — yara_db');
    conn.release();
  })
  .catch(err => {
    console.error('❌ Erro ao conectar no MySQL:', err.message);
    console.error('   Verifique se o XAMPP está rodando e o banco yara_db foi criado.');
  });

module.exports = pool;