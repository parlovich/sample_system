package com.sample.award.dao;

import com.sample.award.model.Award;

import java.util.*;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class AwardsDaoInMemoryImpl implements AwardsDao {

    private final ReadWriteLock readWriteLock = new ReentrantReadWriteLock();


    private final List<Award> awards = new ArrayList<>();
    private final Map<Long, List<Award>> nominatorIndex = new TreeMap<>();
    private final Map<Long, List<Award>> nomineeIndex = new TreeMap<>();

    @Override
    public long create(Award award) {
        readWriteLock.writeLock().lock();
        try {
            long id = awards.size();
            Award newRecord = new Award(id,
                    award.getNominatorId(),
                    award.getNomineeId(),
                    award.getText(),
                    award.getAmount());
            awards.add(newRecord);

            // Update indexes
            if (!nominatorIndex.containsKey(newRecord.getNominatorId())) {
                nominatorIndex.put(newRecord.getNominatorId(), new ArrayList<> ());
            }
            nominatorIndex.get(newRecord.getNominatorId()).add(newRecord);

            if (!nomineeIndex.containsKey(newRecord.getNomineeId())) {
                nomineeIndex.put(newRecord.getNomineeId(), new ArrayList<>());
            }
            nomineeIndex.get(newRecord.getNomineeId()).add(newRecord);
            return id;

        } finally {
            readWriteLock.writeLock().unlock();
        }
    }

    @Override
    public Award findById(long id) {
        return null;
    }

    @Override
    public List<Award> findAll() {
        readWriteLock.readLock().lock();
        try {
            return deepCopy(awards);
        } finally {
            readWriteLock.readLock().unlock();
        }
    }


    @Override
    public List<Award> findByNomineeId(long nomineeId) {
        readWriteLock.readLock().lock();
        try {
            return deepCopy(nomineeIndex.get(nomineeId));
        } finally {
            readWriteLock.readLock().unlock();
        }
    }

    @Override
    public List<Award> findByNominatorId(long nominatorId) {
        readWriteLock.readLock().lock();
        try {
            return deepCopy(nominatorIndex.get(nominatorId));
        } finally {
            readWriteLock.readLock().unlock();
        }
    }

    private List<Award> deepCopy(List<Award> l) {
        //TODO implement deep copy of the list
        return l;
    }

}
