package com.sample.award.service;

import com.sample.award.dao.AwardsDao;
import com.sample.award.model.Award;
import com.sample.users.UsersService;
import com.sample.users.model.User;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Collection;

public class AwardServiceImpl implements AwardService {

    @Autowired
    UsersService usersService;

    @Autowired
    AwardsDao awardsDao;

    @Override
    public Collection<Award> getAllAwards() {
        return awardsDao.findAll();
    }

    @Override
    public long createAward(Award award) {
        User nominator = usersService.getUser(award.getNominatorId());
        User nominee = usersService.getUser(award.getNomineeId());
        if (nominator.getId() == nominee.getId()) {
            throw new RuntimeException("You can't nominate yourself");
        }
        return awardsDao.create(award);
    }

    @Override
    public Collection<Award> getAwardsByNominator(long nominatorId) {
        return awardsDao.findByNominatorId(nominatorId);
    }

    @Override
    public Collection<Award> getAwardsByNominee(long nomineeId) {
        return awardsDao.findByNomineeId(nomineeId);
    }
}
