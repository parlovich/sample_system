package com.sample.award.model;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

@ApiModel
public class Award {

    @ApiModelProperty
    private long id;

    @ApiModelProperty
    private long nominatorId;

    @ApiModelProperty
    private long nomineeId;

    @ApiModelProperty
    private String text;

    @ApiModelProperty
    private double amount;

    public Award() {
    }

    public Award(long nominatorId, long nomineeId, String text, double amount) {
        this(-1, nominatorId, nomineeId, text, amount);
    }

    public Award(long id, long nominatorId, long nomineeId, String text, double amount) {
        this.id = id;
        this.nominatorId = nominatorId;
        this.nomineeId = nomineeId;
        this.text = text;
        this.amount = amount;
    }

    public long getId() {
        return id;
    }

    public long getNominatorId() {
        return nominatorId;
    }

    public long getNomineeId() {
        return nomineeId;
    }

    public String getText() {
        return text;
    }

    public double getAmount() {
        return amount;
    }

    @Override
    public String toString() {
        return "Award{" +
                "id=" + id +
                ", nominatorId=" + nominatorId +
                ", nomineeId=" + nomineeId +
                ", text='" + text + '\'' +
                ", amount=" + amount +
                '}';
    }
}

