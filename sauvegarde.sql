--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8 (Ubuntu 16.8-0ubuntu0.24.10.1)
-- Dumped by pg_dump version 16.8 (Ubuntu 16.8-0ubuntu0.24.10.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: friend_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friend_requests (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    requester_id uuid,
    receiver_id uuid,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    responded_at timestamp without time zone,
    CONSTRAINT friend_requests_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'accepted'::character varying, 'rejected'::character varying])::text[])))
);


ALTER TABLE public.friend_requests OWNER TO postgres;

--
-- Name: friends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friends (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id_1 uuid,
    user_id_2 uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT friends_check CHECK ((user_id_1 < user_id_2))
);


ALTER TABLE public.friends OWNER TO postgres;

--
-- Name: personalities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personalities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    personality_type character varying(50) NOT NULL,
    value character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.personalities OWNER TO postgres;

--
-- Name: personality_links; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personality_links (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    personality_type character varying(50) NOT NULL,
    test_url character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.personality_links OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    bio text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    age integer,
    likes text,
    dislikes text,
    city text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: friend_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friend_requests (id, requester_id, receiver_id, status, created_at, responded_at) FROM stdin;
\.


--
-- Data for Name: friends; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friends (id, user_id_1, user_id_2, created_at) FROM stdin;
\.


--
-- Data for Name: personalities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personalities (id, user_id, personality_type, value, created_at) FROM stdin;
a61d1dbb-d8dd-472f-9c1c-2b4d18a29a68	3756828f-5ed1-44fe-9e4f-a0196e16ab7b	MBTI	INTJ	2025-03-28 12:19:51.8223
644a710b-0b26-4e87-8fc4-8ca095b593f4	3756828f-5ed1-44fe-9e4f-a0196e16ab7b	Enneagramme	6w7	2025-03-28 12:19:51.8223
3a7f7305-f242-4fd6-b88f-139dce9b33b7	5ad35f59-cebc-4004-bc84-b6424df19bed	MBTI	INFJ	2025-03-28 11:15:24.739054
dc88529c-70c9-4321-825b-59d7fdd02dd5	5ad35f59-cebc-4004-bc84-b6424df19bed	Enneagramme	1w9	2025-03-28 11:15:24.739054
79df6bd2-b540-48ca-923d-cdb57abd87c8	5ad35f59-cebc-4004-bc84-b6424df19bed	Big Five	O87 C76 E43 A81 N58	2025-03-28 11:15:24.739054
1998f948-b8b5-4d75-b18b-bfe67e22335f	5ad35f59-cebc-4004-bc84-b6424df19bed	DISC	C	2025-03-28 11:15:24.739054
631ba4b7-bc5b-43ed-b902-c8af47bb4098	5ad35f59-cebc-4004-bc84-b6424df19bed	Haut Potentiel	Oui	2025-03-28 11:15:24.739054
\.


--
-- Data for Name: personality_links; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personality_links (id, personality_type, test_url, description) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password, bio, created_at, age, likes, dislikes, city) FROM stdin;
5ad35f59-cebc-4004-bc84-b6424df19bed	1234	1234@1234	1234	Test	2025-03-28 11:14:18.739837	21		Je n'aime pas tout ce qui est activité en plaine aire	\N
3756828f-5ed1-44fe-9e4f-a0196e16ab7b	test1	test1@test	1234		2025-03-28 12:19:30.75059	21	Les chiens, les plage	Les contacte humain	Paris
\.


--
-- Name: friend_requests friend_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friend_requests
    ADD CONSTRAINT friend_requests_pkey PRIMARY KEY (id);


--
-- Name: friends friends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_pkey PRIMARY KEY (id);


--
-- Name: friends friends_user_id_1_user_id_2_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_user_id_1_user_id_2_key UNIQUE (user_id_1, user_id_2);


--
-- Name: personalities personalities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personalities
    ADD CONSTRAINT personalities_pkey PRIMARY KEY (id);


--
-- Name: personalities personalities_user_id_personality_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personalities
    ADD CONSTRAINT personalities_user_id_personality_type_key UNIQUE (user_id, personality_type);


--
-- Name: personality_links personality_links_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personality_links
    ADD CONSTRAINT personality_links_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: friend_requests friend_requests_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friend_requests
    ADD CONSTRAINT friend_requests_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friend_requests friend_requests_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friend_requests
    ADD CONSTRAINT friend_requests_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friends friends_user_id_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_user_id_1_fkey FOREIGN KEY (user_id_1) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friends friends_user_id_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_user_id_2_fkey FOREIGN KEY (user_id_2) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: personalities personalities_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personalities
    ADD CONSTRAINT personalities_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO api_user;


--
-- Name: TABLE friend_requests; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.friend_requests TO api_user;


--
-- Name: TABLE friends; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.friends TO api_user;


--
-- Name: TABLE personalities; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.personalities TO api_user;


--
-- Name: TABLE personality_links; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.personality_links TO api_user;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users TO api_user;


--
-- PostgreSQL database dump complete
--

