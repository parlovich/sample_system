package com.sample.award.service;

import com.sample.award.model.Award;

import java.util.Collection;
import java.util.List;

public interface AwardService {
    Collection<Award> getAllAwards();

    long createAward(Award award);

    Collection<Award> getAwardsByNominator(long nominatorId);

    Collection<Award> getAwardsByNominee(long nomineeId);
}
