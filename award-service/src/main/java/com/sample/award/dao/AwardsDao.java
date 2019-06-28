package com.sample.award.dao;

import com.sample.award.model.Award;

import java.util.Collection;
import java.util.List;

public interface AwardsDao {
    long create(Award award);

    Award findById(long id);

    Collection<Award> findAll();

    Collection<Award> findByNomineeId(long nomineeId);

    Collection<Award> findByNominatorId(long nominatorId);
}
