-- HidraHabit - Supabase Schema
-- Copie e cole no Editor SQL do Supabase

-- Tabela: usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    peso DECIMAL(5,2),
    meta_diaria_ml INTEGER,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: ingestao_agua
CREATE TABLE IF NOT EXISTS ingestao_agua (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    quantidade_ml INTEGER NOT NULL,
    data_hora TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: metas_diarias
CREATE TABLE IF NOT EXISTS metas_diarias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    meta_ml INTEGER NOT NULL,
    data DATE NOT NULL,
    UNIQUE(usuario_id, data)
);

-- Tabela: lembretes
CREATE TABLE IF NOT EXISTS lembretes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    horario TIME NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela: sequencia_consumo
CREATE TABLE IF NOT EXISTS sequencia_consumo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    dias_consecutivos INTEGER DEFAULT 0,
    ultima_data DATE
);

-- View: resumo_diario_agua
CREATE OR REPLACE VIEW resumo_diario_agua AS
SELECT usuario_id, DATE(data_hora) AS data, SUM(quantidade_ml) AS total_ml
FROM ingestao_agua
GROUP BY usuario_id, DATE(data_hora);

-- RLS (Row Level Security)
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingestao_agua ENABLE ROW LEVEL SECURITY;
ALTER TABLE metas_diarias ENABLE ROW LEVEL SECURITY;
ALTER TABLE lembretes ENABLE ROW LEVEL SECURITY;
ALTER TABLE sequencia_consumo ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso simples (Exemplo: apenas o dono acessa seus dados)
-- Nota: Para produção, use auth.uid() e vincule ao ID do usuário do Supabase Auth.
