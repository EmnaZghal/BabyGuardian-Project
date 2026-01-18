package com.example.profileservice.controller;



import com.example.profileservice.dto.*;
import com.example.profileservice.entity.BabyEntity;
import com.example.profileservice.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService service;

    private String userId(Jwt jwt) {
        return jwt.getSubject(); // Keycloak sub
    }

    private String email(Jwt jwt) {
        // selon ton mapping Keycloak, email peut être null
        return jwt.getClaimAsString("email");
    }

    private static BabyResponse toResp(BabyEntity b) {
        String deviceId = (b.getDevice() != null) ? b.getDevice().getDeviceId() : null;
        return new BabyResponse(
                b.getId(),
                b.getFirstName(),
                b.getGender(),
                b.getBirthDate(),
                b.getGestationalAgeWeeks(),
                b.getWeightKg(),
                deviceId
        );
    }

    // 1) Create baby (owned by current user)
    @PostMapping("/babies")
    public Map<String, Object> createBaby(@AuthenticationPrincipal Jwt jwt,
                                          @RequestBody CreateBabyRequest req) {
        UUID babyId = service.createBabyForUser(userId(jwt), email(jwt), req);
        return Map.of("babyId", babyId);
    }

    // 2) List my babies
    @GetMapping("/me/babies")
    public List<BabyResponse> myBabies(@AuthenticationPrincipal Jwt jwt) {
        return service.listMyBabies(userId(jwt)).stream().map(ProfileController::toResp).toList();
    }

    // 3) Bind device to a baby (1-1)
    @PostMapping("/babies/{babyId}/bind-device")
    public void bindDevice(@AuthenticationPrincipal Jwt jwt,
                           @PathVariable UUID babyId,
                           @RequestBody BindDeviceRequest req) {
        service.bindDeviceToBaby(userId(jwt), babyId, req.deviceId());
    }

    // 4) Unbind device
    @PostMapping("/babies/{babyId}/unbind-device")
    public void unbindDevice(@AuthenticationPrincipal Jwt jwt,
                             @PathVariable UUID babyId) {
        service.unbindDevice(userId(jwt), babyId);
    }

    // 5) Get device of baby
    @GetMapping("/babies/{babyId}/device")
    public Map<String, String> getDevice(@AuthenticationPrincipal Jwt jwt,
                                         @PathVariable UUID babyId) {
        return Map.of("deviceId", service.getDeviceOfBaby(userId(jwt), babyId));
    }

    // 6) ML Profile by deviceId (ownership checked)
    @GetMapping("/me/devices/{deviceId}/ml-profile")
    public MlProfileResponse mlProfile(@AuthenticationPrincipal Jwt jwt,
                                       @PathVariable String deviceId) {
        return service.getMlProfileByDeviceForUser(userId(jwt), deviceId);
    }
}
