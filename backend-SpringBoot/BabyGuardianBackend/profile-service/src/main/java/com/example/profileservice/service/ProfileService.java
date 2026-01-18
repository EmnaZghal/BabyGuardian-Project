package com.example.profileservice.service;



import com.example.profileservice.dto.CreateBabyRequest;
import com.example.profileservice.dto.MlProfileResponse;
import com.example.profileservice.entity.AppUserEntity;
import com.example.profileservice.entity.BabyEntity;
import com.example.profileservice.entity.DeviceEntity;
import com.example.profileservice.repository.AppUserRepository;
import com.example.profileservice.repository.BabyRepository;
import com.example.profileservice.repository.DeviceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final AppUserRepository userRepo;
    private final BabyRepository babyRepo;
    private final DeviceRepository deviceRepo;

    private static final ZoneId ZONE = ZoneId.of("Africa/Tunis");

    /**
     * Crée l'utilisateur local (app_user) si absent.
     * userId = Keycloak sub.
     */
    public AppUserEntity ensureLocalUser(String userId, String email) {
        return userRepo.findById(userId).orElseGet(() -> {
            AppUserEntity u = new AppUserEntity();
            u.setUserId(userId);
            u.setEmail(email);
            return userRepo.save(u);
        });
    }

    @Transactional
    public UUID createBabyForUser(String userId, String email, CreateBabyRequest req) {
        AppUserEntity owner = ensureLocalUser(userId, email);

        BabyEntity b = new BabyEntity();
        b.setFirstName(req.firstName());
        b.setGender(req.gender());
        b.setBirthDate(req.birthDate());
        b.setGestationalAgeWeeks(req.gestationalAgeWeeks());
        b.setWeightKg(req.weightKg());
        b.setOwner(owner);

        b = babyRepo.save(b);
        return b.getId();
    }

    public List<BabyEntity> listMyBabies(String userId) {
        return babyRepo.findByOwner_UserId(userId);
    }

    private BabyEntity requireMyBaby(String userId, UUID babyId) {
        return babyRepo.findByOwner_UserIdAndId(userId, babyId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Baby not found for this user"));
    }

    @Transactional
    public void bindDeviceToBaby(String userId, UUID babyId, String deviceId) {
        BabyEntity baby = requireMyBaby(userId, babyId);

        // device déjà lié à un autre bébé ?
        babyRepo.findByDevice_DeviceId(deviceId).ifPresent(other -> {
            if (!other.getId().equals(babyId)) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Device already bound to another baby");
            }
        });

        // créer le device si n'existe pas
        DeviceEntity dev = deviceRepo.findById(deviceId).orElseGet(() -> {
            DeviceEntity d = new DeviceEntity();
            d.setDeviceId(deviceId);
            return deviceRepo.save(d);
        });

        baby.setDevice(dev);
        babyRepo.save(baby);
    }

    @Transactional
    public void unbindDevice(String userId, UUID babyId) {
        BabyEntity baby = requireMyBaby(userId, babyId);
        baby.setDevice(null);
        babyRepo.save(baby);
    }

    public String getDeviceOfBaby(String userId, UUID babyId) {
        BabyEntity baby = requireMyBaby(userId, babyId);
        if (baby.getDevice() == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No device bound");
        }
        return baby.getDevice().getDeviceId();
    }

    /**
     * Profil ML pour un deviceId, mais uniquement si ce device appartient à un bébé du user connecté.
     */
    public MlProfileResponse getMlProfileByDeviceForUser(String userId, String deviceId) {
        BabyEntity baby = babyRepo.findByDevice_DeviceId(deviceId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Device not bound"));

        // ownership check
        if (!baby.getOwner().getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not your device/baby");
        }

        int ageDays = 0;
        LocalDate birth = baby.getBirthDate();
        if (birth != null) {
            ageDays = (int) ChronoUnit.DAYS.between(birth, LocalDate.now(ZONE));
        }

        return new MlProfileResponse(
                deviceId,
                baby.getId(),
                baby.getFirstName(),
                baby.getGender() != null ? baby.getGender() : 0,
                baby.getGestationalAgeWeeks() != null ? baby.getGestationalAgeWeeks() : 0.0,
                ageDays,
                baby.getWeightKg() != null ? baby.getWeightKg() : 0.0
        );
    }
}
