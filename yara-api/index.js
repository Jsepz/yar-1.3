
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const { connectDB } = require('./database');
const bcrypt = require('bcrypt');

const SALT_ROUNDS = 10;
const app = express();
app.use(express.json());
app.use(cors());

const port = 8080;
const USERS_FILE = path.join(__dirname, 'users.json');

// --- Utilitários para JSON (Fallback) ---
const readUsersJSON = () => {
    try {
        const data = fs.readFileSync(USERS_FILE, 'utf8');
        return JSON.parse(data);
    } catch (err) {
        return [];
    }
};

const saveUsersJSON = (users) => {
    fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2));
};

// --- Rotas da API ---

// Rota de Cadastro
app.post('/signup', async (req, res) => {
    const { nome, email, senha } = req.body;

    // ✅ VALIDAÇÃO — verifica campos vazios antes de qualquer coisa
    if (!nome || nome.trim() === '') {
        return res.status(400).json({ success: false, message: 'O nome é obrigatório' });
    }
    if (!email || email.trim() === '') {
        return res.status(400).json({ success: false, message: 'O e-mail é obrigatório' });
    }
    const emailValido = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    if (!emailValido) {
        return res.status(400).json({ success: false, message: 'Formato de e-mail inválido' });
    }
    if (!senha || senha.trim() === '') {
        return res.status(400).json({ success: false, message: 'A senha é obrigatória' });
    }
    if (senha.length < 6) {
        return res.status(400).json({ success: false, message: 'A senha precisa ter pelo menos 6 caracteres' });
    }

    // ✅ Só gera o hash depois que os campos foram validados
    const senhaHash = await bcrypt.hash(senha, SALT_ROUNDS);

    try {
        const db = await connectDB();
        if (db) {
            const [rows] = await db.execute('SELECT * FROM usuarios WHERE email = ?', [email]);
            if (rows.length > 0) {
                return res.status(400).json({ success: false, message: 'E-mail já cadastrado' });
            }
            // ✅ Coluna correta: senha_hash (igual ao banco que criamos)
            await db.execute(
                'INSERT INTO usuarios (nome, email, senha_hash) VALUES (?, ?, ?)',
                [nome, email, senhaHash]
            );
            return res.status(201).json({ success: true, message: 'Usuário cadastrado com sucesso!' });
        }
    } catch (err) {
        console.log('MySQL não disponível, usando JSON como fallback...');
    }

    // Fallback JSON
    const usuarios = readUsersJSON();
    if (usuarios.find(u => u.email === email)) {
        return res.status(400).json({ success: false, message: 'E-mail já cadastrado' });
    }
    const novoUsuario = { id: Date.now(), nome, email, senha: senhaHash, role: 'user' };
    usuarios.push(novoUsuario);
    saveUsersJSON(usuarios);
    return res.status(201).json({ success: true, message: 'Usuário cadastrado com sucesso!' });
});

// Rota de Login
app.post('/login', async (req, res) => {
    const { email, senha } = req.body;

    // ✅ VALIDAÇÃO
    if (!email || email.trim() === '') {
        return res.status(400).json({ success: false, message: 'O e-mail é obrigatório' });
    }
    if (!senha || senha.trim() === '') {
        return res.status(400).json({ success: false, message: 'A senha é obrigatória' });
    }

    try {
        const db = await connectDB();
        if (db) {
            // Busca só pelo e-mail
            const [rows] = await db.execute('SELECT * FROM usuarios WHERE email = ?', [email]);
            if (rows.length > 0) {
                const usuario = rows[0];
                // ✅ Compara a senha digitada com o hash do banco
                const senhaCorreta = await bcrypt.compare(senha, usuario.senha_hash);
                if (senhaCorreta) {
                    return res.status(200).json({
                        success: true,
                        user: { nome: usuario.nome, email: usuario.email, role: usuario.role },
                        source: 'mysql'
                    });
                } else {
                    return res.status(401).json({ success: false, message: 'E-mail ou senha incorretos' });
                }
            }
        }
    } catch (err) {
        console.log('MySQL não disponível para login, tentando JSON...');
    }

    // Fallback JSON
    const usuarios = readUsersJSON();
    const usuario = usuarios.find(u => u.email === email);
    if (usuario) {
        const senhaCorreta = await bcrypt.compare(senha, usuario.senha);
        if (senhaCorreta) {
            return res.status(200).json({
                success: true,
                user: { nome: usuario.nome, email: usuario.email, role: usuario.role },
                source: 'json'
            });
        }
    }

    return res.status(401).json({ success: false, message: 'E-mail ou senha incorretos' });
});

// Rota de Tradução
app.post('/traduzir', (req, res) => {
    const { texto, from, to } = req.body;

    if (!texto || !from || !to) {
        return res.status(400).json({ success: false, message: 'Informe texto, from e to' });
    }

    const dicionario = {
        'pt-guajajara': { 'bom dia': 'Kwez katu', 'terra': 'Ywy', 'água': 'Y' },
        'guajajara-pt': { 'kwez katu': 'Bom dia', 'ywy': 'Terra', 'y': 'Água' }
    };

    const par = `${from}-${to}`;
    const traducao = dicionario[par]
        ? (dicionario[par][texto.toLowerCase().trim()] || 'Termo não catalogado.')
        : 'Par indisponível.';

    res.json({ original: texto, traduzido: traducao });
});

app.listen(port, () => {
    console.log(`Yara API rodando em http://localhost:${port}`);
});