package com.example.chatbotservice;



import com.example.chatbotservice.dto.AssistantResponse;
import com.example.chatbotservice.dto.ChatRequest;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api")
public class ChatController {

    private final AssistantService assistant;

    public ChatController(AssistantService assistant) {
        this.assistant = assistant;
    }

    @PostMapping("/chat")
    public AssistantResponse chat(@Valid @RequestBody ChatRequest req) {
        // Astuce: tes boutons "questions rapides" peuvent envoyer intent + message pré-rempli
        String msg = normalize(req);
        return new AssistantResponse(assistant.reply(msg));
    }

    @GetMapping("/chat/quick-questions")
    public List<String> quickQuestions() {
        return List.of(
                "Expliquer la dernière alerte",
                "État de santé actuel",
                "Que signifie SpO₂ ?"
        );
    }

    private String normalize(ChatRequest req) {
        if ("DEFINE_SPO2".equals(req.intent())) return "Explique SpO₂ simplement et quand s'inquiéter.";
        return req.message();
    }
}
