package com.example.chatbotservice.config;


import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

@Configuration
public class KnowledgeLoader {

    @Bean
    ApplicationRunner loadKb(/* VectorStore vectorStore */) {
        return args -> {
            var resolver = new PathMatchingResourcePatternResolver();

            Resource[] resources = resolver.getResources("classpath*:/kb/*.md");

            if (resources.length == 0) {
                System.out.println("[KB] Aucun fichier trouvé dans src/main/resources/kb/*.md — démarrage sans KB.");
                return;
            }

            // ici tu fais vectorStore.add(...) etc.
            System.out.println("[KB] Fichiers chargés: " + resources.length);
        };
    }
}

