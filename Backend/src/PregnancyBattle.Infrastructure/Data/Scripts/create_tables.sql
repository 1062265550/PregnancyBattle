-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20) UNIQUE,
    nickname VARCHAR(50),
    avatar_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    last_login_at TIMESTAMP
);

-- 创建孕期信息表
CREATE TABLE IF NOT EXISTS pregnancy_info (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lmp_date DATE NOT NULL,
    due_date DATE NOT NULL,
    calculation_method VARCHAR(20) NOT NULL,
    ultrasound_date DATE,
    ultrasound_weeks INT,
    ultrasound_days INT,
    is_multiple_pregnancy BOOLEAN NOT NULL DEFAULT FALSE,
    fetus_count INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建用户健康档案表
CREATE TABLE IF NOT EXISTS user_health_profiles (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    height DECIMAL(5,2) NOT NULL,
    pre_pregnancy_weight DECIMAL(5,2) NOT NULL,
    current_weight DECIMAL(5,2) NOT NULL,
    blood_type VARCHAR(10),
    age INT NOT NULL,
    medical_history TEXT,
    family_history TEXT,
    allergies_history TEXT,
    obstetric_history TEXT,
    is_smoking BOOLEAN NOT NULL DEFAULT FALSE,
    is_drinking BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建日记表
CREATE TABLE IF NOT EXISTS diaries (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    mood VARCHAR(50),
    diary_date DATE NOT NULL,
    pregnancy_week INT,
    pregnancy_day INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建日记标签表
CREATE TABLE IF NOT EXISTS diary_tags (
    id UUID PRIMARY KEY,
    diary_id UUID NOT NULL REFERENCES diaries(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建日记媒体文件表
CREATE TABLE IF NOT EXISTS diary_media (
    id UUID PRIMARY KEY,
    diary_id UUID NOT NULL REFERENCES diaries(id) ON DELETE CASCADE,
    media_type VARCHAR(20) NOT NULL,
    media_url VARCHAR(500) NOT NULL,
    description VARCHAR(200),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建体重记录表
CREATE TABLE IF NOT EXISTS weight_records (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight DECIMAL(5,2) NOT NULL,
    record_date DATE NOT NULL,
    pregnancy_week INT,
    pregnancy_day INT,
    note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建胎动记录表
CREATE TABLE IF NOT EXISTS fetal_movement_records (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    record_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    count INT NOT NULL,
    duration_minutes INT,
    note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建宫缩记录表
CREATE TABLE IF NOT EXISTS contraction_records (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    record_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    duration_seconds INT,
    intensity VARCHAR(20),
    note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建产检计划表
CREATE TABLE IF NOT EXISTS prenatal_care_plans (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    pregnancy_week INT NOT NULL,
    plan_date DATE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    is_custom BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建产检结果表
CREATE TABLE IF NOT EXISTS prenatal_care_results (
    id UUID PRIMARY KEY,
    plan_id UUID NOT NULL REFERENCES prenatal_care_plans(id) ON DELETE CASCADE,
    result_date DATE NOT NULL,
    doctor_name VARCHAR(50),
    hospital VARCHAR(100),
    note TEXT,
    report_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建待办事项表
CREATE TABLE IF NOT EXISTS todo_items (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    due_date DATE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    priority VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建孕期指南内容表
CREATE TABLE IF NOT EXISTS pregnancy_guides (
    id UUID PRIMARY KEY,
    pregnancy_week INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    content_type VARCHAR(20) NOT NULL,
    target_audience VARCHAR(20) NOT NULL,
    image_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建孕育知识百科表
CREATE TABLE IF NOT EXISTS knowledge_articles (
    id UUID PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建社区帖子表
CREATE TABLE IF NOT EXISTS community_posts (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    view_count INT NOT NULL DEFAULT 0,
    like_count INT NOT NULL DEFAULT 0,
    comment_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建社区评论表
CREATE TABLE IF NOT EXISTS community_comments (
    id UUID PRIMARY KEY,
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    like_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- 创建社区点赞表
CREATE TABLE IF NOT EXISTS community_likes (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES community_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_like_target CHECK (
        (post_id IS NOT NULL AND comment_id IS NULL) OR
        (post_id IS NULL AND comment_id IS NOT NULL)
    )
);

-- 创建用户通知表
CREATE TABLE IF NOT EXISTS user_notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    related_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_phone_number ON users(phone_number);
CREATE INDEX IF NOT EXISTS idx_pregnancy_info_user_id ON pregnancy_info(user_id);
CREATE INDEX IF NOT EXISTS idx_user_health_profiles_user_id ON user_health_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_diaries_user_id ON diaries(user_id);
CREATE INDEX IF NOT EXISTS idx_diaries_diary_date ON diaries(diary_date);
CREATE INDEX IF NOT EXISTS idx_diary_tags_diary_id ON diary_tags(diary_id);
CREATE INDEX IF NOT EXISTS idx_diary_media_diary_id ON diary_media(diary_id);
CREATE INDEX IF NOT EXISTS idx_weight_records_user_id ON weight_records(user_id);
CREATE INDEX IF NOT EXISTS idx_weight_records_record_date ON weight_records(record_date);
CREATE INDEX IF NOT EXISTS idx_fetal_movement_records_user_id ON fetal_movement_records(user_id);
CREATE INDEX IF NOT EXISTS idx_fetal_movement_records_record_date ON fetal_movement_records(record_date);
CREATE INDEX IF NOT EXISTS idx_contraction_records_user_id ON contraction_records(user_id);
CREATE INDEX IF NOT EXISTS idx_contraction_records_record_date ON contraction_records(record_date);
CREATE INDEX IF NOT EXISTS idx_prenatal_care_plans_user_id ON prenatal_care_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_prenatal_care_plans_pregnancy_week ON prenatal_care_plans(pregnancy_week);
CREATE INDEX IF NOT EXISTS idx_prenatal_care_results_plan_id ON prenatal_care_results(plan_id);
CREATE INDEX IF NOT EXISTS idx_todo_items_user_id ON todo_items(user_id);
CREATE INDEX IF NOT EXISTS idx_todo_items_due_date ON todo_items(due_date);
CREATE INDEX IF NOT EXISTS idx_pregnancy_guides_pregnancy_week ON pregnancy_guides(pregnancy_week);
CREATE INDEX IF NOT EXISTS idx_knowledge_articles_category ON knowledge_articles(category);
CREATE INDEX IF NOT EXISTS idx_community_posts_user_id ON community_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_community_posts_category ON community_posts(category);
CREATE INDEX IF NOT EXISTS idx_community_comments_post_id ON community_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_community_comments_user_id ON community_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_community_likes_user_id ON community_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_community_likes_post_id ON community_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_community_likes_comment_id ON community_likes(comment_id);
CREATE INDEX IF NOT EXISTS idx_user_notifications_user_id ON user_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_user_notifications_is_read ON user_notifications(is_read);

-- 创建行级安全策略
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE pregnancy_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_health_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE diaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE diary_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE diary_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE weight_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE fetal_movement_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE contraction_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE prenatal_care_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE prenatal_care_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE todo_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_notifications ENABLE ROW LEVEL SECURITY;

-- 创建用户表的行级安全策略
CREATE POLICY users_policy ON users
    USING (auth.uid() = id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

-- 创建其他表的行级安全策略
CREATE POLICY pregnancy_info_policy ON pregnancy_info
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY user_health_profiles_policy ON user_health_profiles
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY diaries_policy ON diaries
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY diary_tags_policy ON diary_tags
    USING (auth.uid() = (SELECT user_id FROM diaries WHERE id = diary_id) OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY diary_media_policy ON diary_media
    USING (auth.uid() = (SELECT user_id FROM diaries WHERE id = diary_id) OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY weight_records_policy ON weight_records
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY fetal_movement_records_policy ON fetal_movement_records
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY contraction_records_policy ON contraction_records
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY prenatal_care_plans_policy ON prenatal_care_plans
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY prenatal_care_results_policy ON prenatal_care_results
    USING (auth.uid() = (SELECT user_id FROM prenatal_care_plans WHERE id = plan_id) OR auth.uid() = '00000000-0000-0000-0000-000000000000');

CREATE POLICY todo_items_policy ON todo_items
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

-- 社区帖子可以被所有人查看，但只能被作者修改
CREATE POLICY community_posts_select_policy ON community_posts
    FOR SELECT USING (true);

CREATE POLICY community_posts_insert_policy ON community_posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY community_posts_update_policy ON community_posts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY community_posts_delete_policy ON community_posts
    FOR DELETE USING (auth.uid() = user_id);

-- 社区评论可以被所有人查看，但只能被作者修改
CREATE POLICY community_comments_select_policy ON community_comments
    FOR SELECT USING (true);

CREATE POLICY community_comments_insert_policy ON community_comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY community_comments_update_policy ON community_comments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY community_comments_delete_policy ON community_comments
    FOR DELETE USING (auth.uid() = user_id);

-- 社区点赞可以被所有人查看，但只能被作者修改
CREATE POLICY community_likes_select_policy ON community_likes
    FOR SELECT USING (true);

CREATE POLICY community_likes_insert_policy ON community_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY community_likes_delete_policy ON community_likes
    FOR DELETE USING (auth.uid() = user_id);

-- 用户通知只能被通知的接收者查看和修改
CREATE POLICY user_notifications_policy ON user_notifications
    USING (auth.uid() = user_id OR auth.uid() = '00000000-0000-0000-0000-000000000000');

-- 孕期指南和孕育知识百科可以被所有人查看
CREATE POLICY pregnancy_guides_select_policy ON pregnancy_guides
    FOR SELECT USING (true);

CREATE POLICY knowledge_articles_select_policy ON knowledge_articles
    FOR SELECT USING (true);