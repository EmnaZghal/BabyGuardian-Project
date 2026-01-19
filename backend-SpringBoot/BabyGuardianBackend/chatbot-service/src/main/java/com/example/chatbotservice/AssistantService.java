package com.example.chatbotservice;



import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.vectorstore.QuestionAnswerAdvisor;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

@Service
public class AssistantService {

    private final ChatClient chatClient;

    public AssistantService(ChatClient.Builder builder, VectorStore vectorStore) {
        this.chatClient = builder.defaultSystem  ("""
          Tu es BabyGuardian, un assistant d'information générale sur la santé du bébé.
          Tu ne fais pas de diagnostic. En cas de doute ou de signes graves, recommander un médecin/urgence.
          Réponds en français, clair, court, avec des points d'action si utile.
        """)

                .defaultAdvisors(QuestionAnswerAdvisor.builder(vectorStore).build())
                .build();
    }

    public String reply(String message) {
        return chatClient.prompt()
                .user(message)
                .call()
                .content();
    }
}

