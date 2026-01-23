package org.babyguardianbackend.sensorservice.mqttConfig;

import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.core.MessageProducer;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.messaging.MessageChannel;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.messaging.MessageHandler;

import java.util.Arrays;

@Configuration
public class MqttConfig {
    @Value("${app.mqtt.broker}")   private String brokerUri;          // ex: tcp://broker.hivemq.com:1883
    @Value("${app.mqtt.clientId}") private String clientId;           // ex: vitals-${random.value}
    @Value("${app.mqtt.topic}")    private String topic;              // ex: iot/vitals/+
    @Value("${app.mqtt.qos:1}")    private int qos;
    @Value("${app.mqtt.cleanSession:true}") private boolean cleanSession;

    @Bean
    public MqttConnectOptions mqttConnectOptions(
            @Value("${app.mqtt.broker}") String brokerUri,
            @Value("${app.mqtt.cleanSession:true}") boolean cleanSession) {

        MqttConnectOptions opts = new MqttConnectOptions();
        opts.setServerURIs(new String[]{brokerUri});
        opts.setCleanSession(cleanSession);

        // ❌ IMPORTANT : désactiver
        opts.setAutomaticReconnect(false);

        opts.setConnectionTimeout(10);
        opts.setKeepAliveInterval(30);
        return opts;
    }


    @Bean
    public MqttPahoClientFactory mqttClientFactory(MqttConnectOptions opts) {
        DefaultMqttPahoClientFactory f = new DefaultMqttPahoClientFactory();
        f.setConnectionOptions(opts);
        return f;
    }

    @Bean
    public MessageChannel mqttInputChannel() {
        return new DirectChannel();
    }

    @Bean
    public MessageProducer inbound(
            MqttPahoClientFactory factory,
            @Value("${app.mqtt.clientId}") String id,
            @Value("${app.mqtt.topic}") String topics,
            @Value("${app.mqtt.qos:1}") int qos) {

        // nettoie la liste au cas où
        String[] subs = Arrays.stream(topics.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toArray(String[]::new);

        MqttPahoMessageDrivenChannelAdapter adapter =
                new MqttPahoMessageDrivenChannelAdapter(id, factory, subs);

        adapter.setQos(qos);
        adapter.setCompletionTimeout(5000);   // attente SUBACK
        adapter.setOutputChannel(mqttInputChannel());
        return adapter;
    }

    @Bean
    public MessageChannel mqttOutboundChannel() {
        return new DirectChannel();
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttOutboundChannel")
    public MessageHandler mqttOutbound(
            MqttPahoClientFactory factory,
            @Value("${app.mqtt.publisherClientId:spring-publisher-${random.value}}") String pubClientId,
            @Value("${app.mqtt.qos:1}") int qos,
            @Value("${app.mqtt.defaultPublishTopic:iot/alerts/default}") String defaultTopic
    ) {
        MqttPahoMessageHandler handler = new MqttPahoMessageHandler(pubClientId, factory);
        handler.setAsync(true);

        // Si tu oublies TOPIC dans le header, il publiera sur ce topic par défaut
        handler.setDefaultTopic(defaultTopic);
        handler.setDefaultQos(qos);

        return handler;
    }

}