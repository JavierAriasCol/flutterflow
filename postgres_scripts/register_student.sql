CREATE OR REPLACE FUNCTION public.register_student(
    p_user_id TEXT,
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT,
    p_phone_number TEXT DEFAULT NULL,
    p_account_type public.account_type,
    p_whatsapp_consent BOOLEAN DEFAULT FALSE,
    p_origin_name TEXT DEFAULT NULL,
    p_personal_email TEXT DEFAULT NULL,
    p_birth_date TEXT, -- Accepts string or ISO format
    p_nationality TEXT DEFAULT NULL,
    p_ethnicity TEXT DEFAULT NULL,
    p_region TEXT DEFAULT NULL,
    p_degree_type public.degree_type,
    p_university TEXT,
    p_main_degree_category TEXT,
    p_degree_description TEXT DEFAULT NULL,
    p_month_of_graduation TEXT DEFAULT NULL,
    p_year_of_graduation TEXT DEFAULT NULL,
    p_referrer_code TEXT DEFAULT NULL -- Optional referral code
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
    v_display_name TEXT;
    v_birth_date DATE;
    v_referrer_user_id TEXT;
BEGIN
    -- ==========================
    -- BASIC VALIDATIONS
    -- ==========================
    IF p_user_id IS NULL OR trim(p_user_id) = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'VALIDATION_ERROR', 'message', 'user_id is required');
    END IF;
    IF p_email IS NULL OR trim(p_email) = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'VALIDATION_ERROR', 'message', 'email is required');
    END IF;
    IF p_first_name IS NULL OR trim(p_first_name) = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'VALIDATION_ERROR', 'message', 'first_name is required');
    END IF;
    IF p_last_name IS NULL OR trim(p_last_name) = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'VALIDATION_ERROR', 'message', 'last_name is required');
    END IF;
    IF p_degree_type IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'VALIDATION_ERROR', 'message', 'degree_type is required');
    END IF;
    IF p_university IS NULL OR trim(p_university) = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'VALIDATION_ERROR', 'message', 'university is required');
    END IF;

    -- ==========================
    -- PARSE BIRTH DATE (flexible input)
    -- ==========================
    BEGIN
        IF p_birth_date IS NULL OR trim(p_birth_date) = '' THEN
            v_birth_date := NULL;
        ELSE
            BEGIN
                -- Try ISO format first (YYYY-MM-DD)
                v_birth_date := to_date(trim(p_birth_date), 'YYYY-MM-DD');
            EXCEPTION WHEN others THEN
                BEGIN
                    -- Try alternative format (DD/MM/YYYY)
                    v_birth_date := to_date(trim(p_birth_date), 'DD/MM/YYYY');
                EXCEPTION WHEN others THEN
                    RETURN jsonb_build_object(
                        'success', false,
                        'error', 'INVALID_DATE_FORMAT',
                        'message', 'Invalid birth_date format. Use YYYY-MM-DD or DD/MM/YYYY.'
                    );
                END;
            END;
        END IF;
    END;

    -- Build full display name
    v_display_name := trim(p_first_name) || ' ' || trim(p_last_name);

    -- ==========================
    -- ATOMIC TRANSACTION
    -- ==========================
    BEGIN
        -- Check for duplicates: user_id or email
        IF EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
            RETURN jsonb_build_object('success', false, 'error', 'DUPLICATE_USER_ID', 'message', 'A user with this ID already exists');
        END IF;
        IF EXISTS (SELECT 1 FROM public.users WHERE email = trim(p_email)) THEN
            RETURN jsonb_build_object('success', false, 'error', 'DUPLICATE_EMAIL', 'message', 'This email is already registered');
        END IF;

        -- ==========================
        -- INSERT INTO users
        -- ==========================
        INSERT INTO public.users (
            id,
            email,
            display_name,
            phone_number,
            account_type,
            whatsapp_consent
        ) VALUES (
            p_user_id,
            trim(p_email),
            v_display_name,
            trim(p_phone_number),
            p_account_type,
            COALESCE(p_whatsapp_consent, FALSE)
        );

        -- ==========================
        -- INSERT INTO students
        -- ==========================
        INSERT INTO public.students (
            user_id,
            origin_name,
            first_name,
            last_name,
            personal_email,
            birth_date,
            nationality,
            ethnicity,
            region,
            degree_type,
            university,
            main_degree_category,
            degree_description,
            month_of_graduation,
            year_of_graduation
        ) VALUES (
            p_user_id,
            trim(p_origin_name),
            trim(p_first_name),
            trim(p_last_name),
            trim(p_personal_email),
            v_birth_date,
            trim(p_nationality),
            trim(p_ethnicity),
            trim(p_region),
            p_degree_type,
            trim(p_university),
            trim(p_main_degree_category),
            trim(p_degree_description),
            trim(p_month_of_graduation),
            trim(p_year_of_graduation)
        );

        -- ==========================
        -- HANDLE REFERRAL LINKING (optional)
        -- ==========================
        IF p_referrer_code IS NOT NULL AND trim(p_referrer_code) <> '' THEN
            SELECT user_id INTO v_referrer_user_id
            FROM public.students
            WHERE referral_code = trim(p_referrer_code)
            LIMIT 1;

            IF v_referrer_user_id IS NOT NULL THEN
                INSERT INTO public.user_referral (new_user_id, referrer_id)
                VALUES (p_user_id, v_referrer_user_id);
            END IF;
            -- If referrer_code not found, skip linking silently
        END IF;

        -- ✅ SUCCESS
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Student successfully registered',
            'data', jsonb_build_object(
                'user_id', p_user_id,
                'display_name', v_display_name,
                'email', trim(p_email),
                'university', trim(p_university),
                'degree_type', p_degree_type
            )
        );

    EXCEPTION
        WHEN unique_violation THEN
            RETURN jsonb_build_object('success', false, 'error', 'DUPLICATE_DATA', 'message', 'A record with the same unique data already exists');
        WHEN foreign_key_violation THEN
            RETURN jsonb_build_object('success', false, 'error', 'INVALID_REFERENCE', 'message', 'Invalid reference found in data');
        WHEN OTHERS THEN
            RETURN jsonb_build_object('success', false, 'error', 'DATABASE_ERROR', 'message', 'Internal error: ' || SQLERRM);
    END;
END;
$$;
