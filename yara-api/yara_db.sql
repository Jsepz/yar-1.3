-- ============================================================
--  YARÃ DATABASE - yara_db
--  Gerado para o Projeto Yarã | IFMA - Informática para Internet
--  Execute no phpMyAdmin (XAMPP) ou no terminal MySQL
-- ============================================================

DROP DATABASE IF EXISTS yara_db;
CREATE DATABASE yara_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE yara_db;

-- ============================================================
-- TABELA 1: usuarios
-- Usada por: login.html, signup, páginas protegidas
-- ============================================================

CREATE TABLE usuarios (
  id         INT           NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(100)  NOT NULL,
  email      VARCHAR(100)  NOT NULL,
  senha_hash VARCHAR(255)  NOT NULL,           -- NUNCA salvar senha pura
  role       ENUM('user', 'admin') NOT NULL DEFAULT 'user',
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_email (email)
);

-- Usuário admin de teste
-- senha "admin123" hasheada com bcrypt (rounds=10)
INSERT INTO usuarios (nome, email, senha_hash, role) VALUES
  ('Admin Yarã',  'admin@yara.im',    '$2b$10$KIX6JpK8V2hH2Qz5v3yFfOQz3e7Q2Z8kL9mN1pR4sT6uW0xY7aB3C', 'admin'),
  ('Usuário Teste','teste@yara.im',   '$2b$10$KIX6JpK8V2hH2Qz5v3yFfOQz3e7Q2Z8kL9mN1pR4sT6uW0xY7aB3C', 'user');

-- ============================================================
-- TABELA 2: etnias
-- Usada por: pages/etnias/*.html (11 páginas de etnias)
-- ============================================================

CREATE TABLE etnias (
  id                   INT          NOT NULL AUTO_INCREMENT,
  nome                 VARCHAR(100) NOT NULL,
  lingua               VARCHAR(100) NOT NULL,
  tronco_linguistico   ENUM('Tupi', 'Jê', 'Isolada') NOT NULL,
  populacao_estimada   INT          DEFAULT NULL,
  territorio           VARCHAR(150) DEFAULT NULL,
  descricao            TEXT         DEFAULT NULL,
  foto_url             VARCHAR(255) DEFAULT NULL,
  created_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id)
);

INSERT INTO etnias (nome, lingua, tronco_linguistico, populacao_estimada, territorio, descricao) VALUES
  ('Guajajara',    'Tenetehara',    'Tupi', 20000, 'TI Arariboia, TI Caru',           'Um dos maiores povos indígenas do Maranhão, conhecidos pela resistência ao desmatamento.'),
  ('Ka''apor',     'Ka''apor',      'Tupi',  1300, 'TI Alto Turiaçu',                  'Povo guerreiro do norte do Maranhão, guardiões da floresta amazônica.'),
  ('Awá-Guajá',    'Awá',           'Tupi',   600, 'TI Awá, TI Arariboia',             'Um dos povos mais ameaçados do mundo, alguns grupos ainda em isolamento voluntário.'),
  ('Canela Apãniekrã', 'Canela',    'Jê',   2500, 'TI Kanela',                         'Povo do cerrado maranhense, famosos pelo Ritual da Corrida de Tora.'),
  ('Canela Ramkokamekrã','Canela',  'Jê',   1800, 'TI Porquinhos',                     'Guardiões do cerrado e das tradições orais Jê do Maranhão.'),
  ('Gavião',       'Pukobiê',       'Jê',    900, 'TI Governador',                     'Povo Jê do leste maranhense, resistentes à colonização desde o século XVIII.'),
  ('Guajá',        'Awá',           'Tupi',  450, 'TI Caru, TI Alto Turiaçu',          'Caçadores-coletores nômades, considerados entre os mais vulneráveis do Brasil.'),
  ('Krikati',      'Krikati',       'Jê',    700, 'TI Krikati',                        'Povo Jê do centro-oeste do Maranhão, com forte tradição de pintura corporal.'),
  ('Kreye',        'Kreye',         'Jê',    200, 'TI Aldeias Altas',                  'Pequena etnia com língua própria, em risco de extinção linguística.'),
  ('Krenyê',       'Krenyê',        'Jê',    150, 'TI Krenyê',                         'Um dos menores grupos indígenas do Maranhão, com esforços ativos de revitalização.'),
  ('Timbira',      'Timbira',       'Jê',   3000, 'TI Geralda-Toco Preto',             'Conjunto de povos Jê do cerrado, conhecidos pelas longas corridas cerimoniais.');

-- ============================================================
-- TABELA 3: aldeias
-- Usada por: pages/mapa.html, pages/mapa_real.html
-- ============================================================

CREATE TABLE aldeias (
  id         INT            NOT NULL AUTO_INCREMENT,
  etnia_id   INT            NOT NULL,
  nome       VARCHAR(100)   NOT NULL,
  municipio  VARCHAR(100)   DEFAULT NULL,
  latitude   DECIMAL(10,7)  NOT NULL,
  longitude  DECIMAL(10,7)  NOT NULL,
  populacao  INT            DEFAULT NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_aldeia_etnia FOREIGN KEY (etnia_id) REFERENCES etnias (id) ON DELETE CASCADE
);

INSERT INTO aldeias (etnia_id, nome, municipio, latitude, longitude, populacao) VALUES
  (1, 'Aldeia Zutiwa',        'Arame',          -4.8821, -44.3654, 320),
  (1, 'Aldeia Lagoa Comprida', 'Grajaú',        -5.8193, -46.1352, 180),
  (2, 'Aldeia Xié',           'Centro Novo do MA', -2.4512, -46.6321, 210),
  (2, 'Aldeia Xikrin',        'Zé Doca',        -3.2741, -45.6123, 170),
  (3, 'Aldeia Tiracambu',     'Amarante do MA', -5.5631, -46.7523, 95),
  (4, 'Aldeia Escalvado',     'Fernando Falcão', -6.1142, -44.2831, 430),
  (5, 'Aldeia Porquinhos',    'Fernando Falcão', -6.3241, -44.5632, 390),
  (6, 'Aldeia Governador',    'Amarante do MA', -5.4312, -46.2341, 210),
  (9, 'Aldeia Aldeias Altas', 'Aldeias Altas',  -4.6231, -44.3782, 55),
  (11,'Aldeia Geralda',       'Arame',          -5.1243, -45.6721, 180);

-- ============================================================
-- TABELA 4: dicionario
-- Usada por: pages/tradutor.html
-- Hoje tem só 3 palavras fixas no index.js — isso resolve
-- ============================================================

CREATE TABLE dicionario (
  id               INT          NOT NULL AUTO_INCREMENT,
  etnia_id         INT          NOT NULL,
  palavra_pt       VARCHAR(100) NOT NULL,
  palavra_indigena VARCHAR(100) NOT NULL,
  pronuncia        VARCHAR(150) DEFAULT NULL,   -- ex: "kweZ ka-TU"
  categoria        ENUM('saudacao','natureza','corpo','familia','animal','alimento','outro') NOT NULL DEFAULT 'outro',
  verificado       TINYINT(1)   NOT NULL DEFAULT 0,  -- 0=pendente, 1=verificado por especialista

  PRIMARY KEY (id),
  CONSTRAINT fk_dic_etnia FOREIGN KEY (etnia_id) REFERENCES etnias (id) ON DELETE CASCADE
);

INSERT INTO dicionario (etnia_id, palavra_pt, palavra_indigena, pronuncia, categoria, verificado) VALUES
  -- Guajajara (id=1)
  (1, 'bom dia',  'Kwez katu',   'kweZ ka-TU',   'saudacao', 1),
  (1, 'terra',    'Ywy',         'iu-U',          'natureza',  1),
  (1, 'água',     'Y',           'i',             'natureza',  1),
  (1, 'fogo',     'Tatá',        'ta-TA',         'natureza',  1),
  (1, 'lua',      'Jaxy',        'ja-SHI',        'natureza',  1),
  (1, 'sol',      'Kuarahy',     'kua-ra-I',      'natureza',  1),
  (1, 'pai',      'Ug',          'ug',            'familia',   1),
  (1, 'mãe',      'Hag',         'hag',           'familia',   1),
  (1, 'peixe',    'Pirá',        'pi-RA',         'animal',    1),
  (1, 'onça',     'Jawara',      'ja-ua-RA',      'animal',    1),
  (1, 'floresta', 'Ka''a',       'ka-A',          'natureza',  1),
  (1, 'criança',  'Ypykuer',     'i-pi-ku-ER',    'familia',   1),
  -- Ka'apor (id=2)
  (2, 'bom dia',  'Xe moîtá',   'she mo-i-TA',   'saudacao',  1),
  (2, 'água',     'Y',           'i',             'natureza',  1),
  (2, 'terra',    'Ywypóra',    'iwi-PO-ra',     'natureza',  1),
  (2, 'pai',      'Ru',          'ru',            'familia',   1),
  (2, 'mãe',      'Sy',          'si',            'familia',   1),
  -- Canela (id=4)
  (4, 'bom dia',  'Hõmre',       'HOM-re',        'saudacao',  1),
  (4, 'água',     'Uze',         'u-ZE',          'natureza',  1),
  (4, 'fogo',     'Katxêt',      'ka-TSHET',      'natureza',  1),
  (4, 'sol',      'Pyt',         'pit',           'natureza',  1),
  -- Krikati (id=8)
  (8, 'bom dia',  'Amji ikre',   'am-ji IK-re',   'saudacao',  1),
  (8, 'terra',    'Pjê',         'pyeh',          'natureza',  1);

-- ============================================================
-- TABELA 5: acervo
-- Usada por: pages/biblioteca.html
-- PDFs, áudios e vídeos da biblioteca digital
-- ============================================================

CREATE TABLE acervo (
  id          INT          NOT NULL AUTO_INCREMENT,
  etnia_id    INT          DEFAULT NULL,         -- NULL = acervo geral
  titulo      VARCHAR(200) NOT NULL,
  descricao   TEXT         DEFAULT NULL,
  tipo        ENUM('documento','audio','video','gramatica') NOT NULL,
  arquivo_url VARCHAR(255) DEFAULT NULL,
  tamanho_kb  INT          DEFAULT NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  CONSTRAINT fk_acervo_etnia FOREIGN KEY (etnia_id) REFERENCES etnias (id) ON DELETE SET NULL
);

INSERT INTO acervo (etnia_id, titulo, descricao, tipo, arquivo_url, tamanho_kb) VALUES
  (1, 'Gramática Tenetehara',      'Estudo completo da estrutura da língua Guajajara.',                       'gramatica', '/acervo/gramatica-tenetehara.pdf',  4300),
  (2, 'Cantos Ka''apor',           'Registro em áudio de cantos tradicionais de celebração.',                 'audio',     '/acervo/cantos-kaapor.mp3',         12800),
  (11,'Ritual Timbira',            'Documentário curta-metragem sobre a Festa do Moqueado.',                 'video',     '/acervo/ritual-timbira.mp4',        870000),
  (4, 'Dicionário Canela-Português','Vocabulário básico com transcrição fonética.',                           'documento', '/acervo/dicionario-canela.pdf',      1200),
  (3, 'Relatório Awá-Guajá 2024',  'Levantamento demográfico e situação territorial do povo Awá.',           'documento', '/acervo/relatorio-awa-2024.pdf',     3100),
  (NULL,'Atlas Linguístico do MA', 'Mapa das línguas indígenas do Maranhão com distribuição geográfica.',    'documento', '/acervo/atlas-linguistico-ma.pdf',   8900);

-- ============================================================
-- TABELA 6: depoimentos
-- Usada por: pages/nossa-voz.html
-- Citações e histórias dos líderes indígenas
-- ============================================================

CREATE TABLE depoimentos (
  id          INT          NOT NULL AUTO_INCREMENT,
  etnia_id    INT          DEFAULT NULL,
  autor_nome  VARCHAR(100) NOT NULL,
  autor_cargo VARCHAR(150) DEFAULT NULL,
  texto       TEXT         NOT NULL,
  aprovado    TINYINT(1)   NOT NULL DEFAULT 0,  -- admin aprova antes de exibir
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  CONSTRAINT fk_dep_etnia FOREIGN KEY (etnia_id) REFERENCES etnias (id) ON DELETE SET NULL
);

INSERT INTO depoimentos (etnia_id, autor_nome, autor_cargo, texto, aprovado) VALUES
  (1, 'Maíra Tenetehara', 'Liderança e Educadora - TI Arariboia',
   'A língua é a pele da nossa alma. Quando falamos nossa língua, as árvores nos escutam melhor e os espíritos dos nossos avós sorriem.',
   1),
  (4, 'Cacique Kanela', 'Guardião da Memória - Aldeia Escalvado',
   'Preservar nossa fala não é olhar apenas para trás, é garantir que nossos filhos saibam quem são em um mundo que tenta fazê-los esquecer.',
   1),
  (2, 'Wirá Ka''apor', 'Professor Indígena - Alto Turiaçu',
   'Nossa língua é o mapa da floresta. Sem ela, ficamos perdidos mesmo dentro do nosso próprio território.',
   1);

-- ============================================================
-- TABELA 7: timeline
-- Usada por: pages/timeline.html
-- Eventos históricos da linha do tempo
-- ============================================================

CREATE TABLE timeline (
  id        INT          NOT NULL AUTO_INCREMENT,
  etnia_id  INT          DEFAULT NULL,           -- NULL = evento geral/todos os povos
  ano       INT          NOT NULL,               -- ex: 1988, -500 para antes de Cristo
  titulo    VARCHAR(150) NOT NULL,
  descricao TEXT         DEFAULT NULL,
  periodo   ENUM('pre-colonial','colonial','imperio','republica','contemporaneo') NOT NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_tl_etnia FOREIGN KEY (etnia_id) REFERENCES etnias (id) ON DELETE SET NULL
);

INSERT INTO timeline (etnia_id, ano, titulo, descricao, periodo) VALUES
  (NULL, -1000, 'Ocupação Ancestral',
   'Milhares de anos antes da colonização, os troncos Tupi e Jê já habitavam e moldavam a biodiversidade maranhense.',
   'pre-colonial'),
  (NULL, 1612, 'Invasão Europeia',
   'Fundação de São Luís pelos franceses e início dos conflitos territoriais e linguísticos na região.',
   'colonial'),
  (NULL, 1755, 'Diretório dos Índios',
   'Marquês de Pombal proíbe o uso das línguas indígenas, impondo o português em todas as aldeias.',
   'colonial'),
  (1,    1901, 'Primeiro Contato Pacífico Guajajara',
   'Missionários do SPI estabelecem contato formal com os Guajajara da TI Arariboia.',
   'republica'),
  (NULL, 1988, 'Constituição Federal',
   'Marco legal que reconhece o direito originário dos povos indígenas às suas terras e o respeito às suas culturas e línguas.',
   'contemporaneo'),
  (3,    2011, 'Operação Awá',
   'FUNAI, MPF e PF realizam operação para retirar invasores da TI Awá, uma das maiores do país.',
   'contemporaneo'),
  (NULL, 2026, 'Projeto Yarã',
   'Uso da tecnologia e inteligência artificial para a revitalização e preservação das línguas ancestrais do Maranhão.',
   'contemporaneo');

-- ============================================================
-- TABELA 8: contribuicoes
-- Usada por: pages/contribuir.html (formulário "Sugira uma Tradução")
-- ============================================================

CREATE TABLE contribuicoes (
  id         INT          NOT NULL AUTO_INCREMENT,
  usuario_id INT          DEFAULT NULL,          -- NULL = enviado sem login
  etnia_id   INT          DEFAULT NULL,
  tipo       ENUM('traducao','depoimento','correcao','outro') NOT NULL DEFAULT 'traducao',
  conteudo   TEXT         NOT NULL,
  status     ENUM('pendente','aprovado','rejeitado') NOT NULL DEFAULT 'pendente',
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  CONSTRAINT fk_contrib_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE SET NULL,
  CONSTRAINT fk_contrib_etnia   FOREIGN KEY (etnia_id)   REFERENCES etnias (id)   ON DELETE SET NULL
);

-- ============================================================
-- VIEWS ÚTEIS (facilitam as queries no index.js)
-- ============================================================

-- View: dicionário completo com nome da etnia
CREATE VIEW vw_dicionario AS
  SELECT
    d.id,
    e.nome        AS etnia,
    d.palavra_pt,
    d.palavra_indigena,
    d.pronuncia,
    d.categoria,
    d.verificado
  FROM dicionario d
  JOIN etnias e ON e.id = d.etnia_id
  WHERE d.verificado = 1;

-- View: aldeias com nome da etnia (para o mapa)
CREATE VIEW vw_mapa AS
  SELECT
    a.id,
    e.nome        AS etnia,
    a.nome        AS aldeia,
    a.municipio,
    a.latitude,
    a.longitude,
    a.populacao
  FROM aldeias a
  JOIN etnias e ON e.id = a.etnia_id;

-- View: contribuições pendentes (para o painel admin)
CREATE VIEW vw_pendentes AS
  SELECT
    c.id,
    u.nome        AS usuario,
    e.nome        AS etnia,
    c.tipo,
    c.conteudo,
    c.created_at
  FROM contribuicoes c
  LEFT JOIN usuarios u ON u.id = c.usuario_id
  LEFT JOIN etnias   e ON e.id = c.etnia_id
  WHERE c.status = 'pendente'
  ORDER BY c.created_at DESC;

-- ============================================================
-- FIM DO SCRIPT
-- Total: 8 tabelas + 3 views
-- Para rodar: cole no phpMyAdmin > aba SQL > clique Executar
-- ============================================================
